/*
# EduRecord SECURITY DEFINER Functions & Triggers

## Overview
Creates server-side functions for privileged operations that must NOT be
directly writable by the client:
1. Auto-create profile on user signup (trigger)
2. Audit logging function
3. Role management (set_user_role)
4. User activation/deactivation (set_user_active)
5. updated_at trigger function

## Functions Created

### 1. handle_new_user() — TRIGGER function
- Fires AFTER INSERT on auth.users (on new user signup).
- Creates a corresponding row in public.profiles with default role 'viewer'.
- The new user's full_name is pulled from raw_user_meta_data if provided at signup.
- This function is SECURITY DEFINER so it can write to profiles even during the
  auth flow before the user has an authenticated session.

### 2. log_action() — SECURITY DEFINER
- Inserts a row into audit_logs with the current user as actor.
- Parameters: p_action (text), p_entity_type (text), p_entity_id (uuid), p_metadata (jsonb).
- Uses auth.uid() to set actor_id — prevents actor forgery.
- Returns the inserted row id.
- Callable by any authenticated user (EXECUTE TO authenticated).

### 3. set_user_role() — SECURITY DEFINER
- Changes a user's role in profiles.
- Parameters: p_user_id (uuid), p_role (text).
- Only callable by admins (checked inside function body).
- Validates role is one of admin/staff/viewer.
- Returns the updated profile.
- EXECUTE TO authenticated (but only admins succeed).

### 4. set_user_active() — SECURITY DEFINER
- Activates or deactivates a user.
- Parameters: p_user_id (uuid), p_is_active (boolean).
- Only callable by admins.
- EXECUTE TO authenticated (but only admins succeed).

### 5. update_updated_at() — TRIGGER function
- Generic trigger to auto-update updated_at on row modification.
- Applied to all tables with updated_at columns.

## Security Notes
1. All functions use SECURITY DEFINER with explicit SET search_path = public.
2. Role and is_active are NEVER writable by the client directly — only through these functions.
3. log_action uses auth.uid() so the actor is always the real caller.
4. set_user_role and set_user_active check is_admin() internally, not just via RLS.
*/

-- ============================================================
-- 1. handle_new_user — auto-create profile on signup
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role, is_active)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    'viewer',
    true
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- 2. log_action — audit logging
-- ============================================================
CREATE OR REPLACE FUNCTION public.log_action(
  p_action text,
  p_entity_type text DEFAULT NULL,
  p_entity_id uuid DEFAULT NULL,
  p_metadata jsonb DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id uuid;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required to log actions';
  END IF;

  INSERT INTO public.audit_logs (actor_id, action, entity_type, entity_id, metadata)
  VALUES (auth.uid(), p_action, p_entity_type, p_entity_id, p_metadata)
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.log_action(text, text, uuid, jsonb) TO authenticated;

-- ============================================================
-- 3. set_user_role — admin-only role management
-- ============================================================
CREATE OR REPLACE FUNCTION public.set_user_role(
  p_user_id uuid,
  p_role text
)
RETURNS public.profiles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_profile public.profiles;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only administrators can change user roles';
  END IF;

  IF p_role NOT IN ('admin', 'staff', 'viewer') THEN
    RAISE EXCEPTION 'Invalid role: %', p_role;
  END IF;

  -- Prevent self-demotion (admin removing their own admin role)
  IF p_user_id = auth.uid() AND p_role != 'admin' THEN
    RAISE EXCEPTION 'Cannot remove your own admin role';
  END IF;

  UPDATE public.profiles
  SET role = p_role, updated_at = now()
  WHERE id = p_user_id
  RETURNING * INTO v_profile;

  IF v_profile IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  -- Log the role change
  INSERT INTO public.audit_logs (actor_id, action, entity_type, entity_id, metadata)
  VALUES (auth.uid(), 'user.role_change', 'profile', p_user_id,
    jsonb_build_object('new_role', p_role));

  RETURN v_profile;
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_user_role(uuid, text) TO authenticated;

-- ============================================================
-- 4. set_user_active — admin-only activation/deactivation
-- ============================================================
CREATE OR REPLACE FUNCTION public.set_user_active(
  p_user_id uuid,
  p_is_active boolean
)
RETURNS public.profiles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_profile public.profiles;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only administrators can activate or deactivate users';
  END IF;

  IF p_user_id = auth.uid() AND p_is_active = false THEN
    RAISE EXCEPTION 'Cannot deactivate your own account';
  END IF;

  UPDATE public.profiles
  SET is_active = p_is_active, updated_at = now()
  WHERE id = p_user_id
  RETURNING * INTO v_profile;

  IF v_profile IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  INSERT INTO public.audit_logs (actor_id, action, entity_type, entity_id, metadata)
  VALUES (auth.uid(), 'user.active_change', 'profile', p_user_id,
    jsonb_build_object('is_active', p_is_active));

  RETURN v_profile;
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_user_active(uuid, boolean) TO authenticated;

-- ============================================================
-- 5. update_updated_at — generic trigger for updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Apply updated_at triggers to all tables with updated_at column
DROP TRIGGER IF EXISTS profiles_updated_at ON public.profiles;
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS students_updated_at ON public.students;
CREATE TRIGGER students_updated_at
  BEFORE UPDATE ON public.students
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS records_updated_at ON public.records;
CREATE TRIGGER records_updated_at
  BEFORE UPDATE ON public.records
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS documents_updated_at ON public.documents;
CREATE TRIGGER documents_updated_at
  BEFORE UPDATE ON public.documents
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS expiry_alerts_updated_at ON public.expiry_alerts;
CREATE TRIGGER expiry_alerts_updated_at
  BEFORE UPDATE ON public.expiry_alerts
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS settings_updated_at ON public.settings;
CREATE TRIGGER settings_updated_at
  BEFORE UPDATE ON public.settings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
