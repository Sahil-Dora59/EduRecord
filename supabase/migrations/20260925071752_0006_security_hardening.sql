/*
# EduRecord Security Hardening — Revoke anon EXECUTE and fix search_path

## Overview
Fixes security advisor findings:
1. Revoke EXECUTE on SECURITY DEFINER functions from anon and public roles.
2. Set explicit search_path on update_updated_at trigger function.
3. Grant EXECUTE only to authenticated where appropriate.

## Changes

### Functions whose EXECUTE is revoked from anon/public:
- handle_new_user(): trigger function — should only be called by the trigger, not via RPC. Revoke from anon and public.
- is_admin(): helper for RLS policies — revoke from anon and public. Keep authenticated (needed for RLS policy evaluation, but RLS uses SECURITY DEFINER context).
- is_staff_or_admin(): same as is_admin.
- log_action(): revoke from anon. Keep authenticated (explicitly granted).
- set_user_role(): revoke from anon. Keep authenticated (explicitly granted).
- set_user_active(): revoke from anon. Keep authenticated (explicitly granted).

### search_path fix:
- update_updated_at(): add SET search_path = public.

## Important Notes
1. RLS policies that call is_admin()/is_staff_or_admin() still work because
   the functions run as SECURITY DEFINER and query profiles directly.
2. handle_new_user is a trigger — it runs in the context of the trigger,
   not via RPC, so revoking EXECUTE from anon/public is safe.
3. The explicit GRANT EXECUTE TO authenticated on log_action, set_user_role,
   and set_user_active is preserved.
*/

-- Revoke EXECUTE from anon and public on all SECURITY DEFINER functions
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.is_staff_or_admin() FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.log_action(text, text, uuid, jsonb) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.set_user_role(uuid, text) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.set_user_active(uuid, boolean) FROM anon, public;

-- Fix search_path on update_updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;
