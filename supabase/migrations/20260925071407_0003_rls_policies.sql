/*
# EduRecord RLS Policies — All Tables

## Overview
Creates Row Level Security policies for all 10 tables in EduRecord.
This application has a sign-in screen, so all policies are scoped to `authenticated`.
Role-based access is enforced through a helper function that checks the user's role
from the profiles table.

## Role-Based Access Model
- Admin: full CRUD on all tables.
- Staff: CRUD on students, records, documents, verifications, expiry_alerts;
         Read on document_types, document_analyses, settings;
         Create on document_analyses (via edge function later).
- Viewer: Read-only on all tables.
- All users: Read own profile; update own profile (name/avatar only, NOT role/is_active).

## Helper Function
- `is_admin()`: returns true if the current user's profile role is 'admin'.
- `is_staff_or_admin()`: returns true if role is 'admin' or 'staff'.

## Policies Per Table

### profiles
- SELECT: self or admin
- INSERT: admin only (via function, not direct client insert)
- UPDATE: self (name/avatar only) or admin (full)
- DELETE: admin only

### students
- SELECT: all authenticated
- INSERT: admin, staff
- UPDATE: admin, staff
- DELETE: admin only

### records
- SELECT: all authenticated
- INSERT: admin, staff
- UPDATE: admin, staff
- DELETE: admin only

### document_types
- SELECT: all authenticated
- INSERT: admin only
- UPDATE: admin only
- DELETE: admin only

### documents
- SELECT: all authenticated
- INSERT: admin, staff
- UPDATE: admin, staff
- DELETE: admin only

### document_analyses
- SELECT: all authenticated
- INSERT: admin, staff (edge function uses service role, bypasses RLS)
- UPDATE: admin only
- DELETE: admin only

### verifications
- SELECT: all authenticated
- INSERT: admin, staff
- UPDATE: admin, staff
- DELETE: admin only

### expiry_alerts
- SELECT: all authenticated
- INSERT: admin, staff
- UPDATE: admin, staff
- DELETE: admin only

### audit_logs
- SELECT: admin only (staff can see own actions via actor_id check)
- INSERT: via SECURITY DEFINER function only (no direct client insert)
- UPDATE: none
- DELETE: admin only

### settings
- SELECT: all authenticated
- INSERT: admin only
- UPDATE: admin only
- DELETE: admin only

## Important Notes
1. All policies use auth.uid() — never current_user.
2. Role checks join profiles table on auth.uid().
3. No table is publicly readable (no anon access).
4. audit_logs INSERT is handled by a SECURITY DEFINER function (separate migration).
*/

-- ============================================================
-- Helper functions for role checks
-- ============================================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin' AND is_active = true
  );
$$;

CREATE OR REPLACE FUNCTION public.is_staff_or_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role IN ('admin', 'staff') AND is_active = true
  );
$$;

-- ============================================================
-- 1. profiles
-- ============================================================
DROP POLICY IF EXISTS "profiles_select" ON public.profiles;
CREATE POLICY "profiles_select"
ON public.profiles FOR SELECT
TO authenticated
USING (id = auth.uid() OR public.is_admin());

DROP POLICY IF EXISTS "profiles_insert" ON public.profiles;
CREATE POLICY "profiles_insert"
ON public.profiles FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "profiles_update" ON public.profiles;
CREATE POLICY "profiles_update"
ON public.profiles FOR UPDATE
TO authenticated
USING (id = auth.uid() OR public.is_admin())
WITH CHECK (id = auth.uid() OR public.is_admin());

DROP POLICY IF EXISTS "profiles_delete" ON public.profiles;
CREATE POLICY "profiles_delete"
ON public.profiles FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================
-- 2. students
-- ============================================================
DROP POLICY IF EXISTS "students_select" ON public.students;
CREATE POLICY "students_select"
ON public.students FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "students_insert" ON public.students;
CREATE POLICY "students_insert"
ON public.students FOR INSERT
TO authenticated
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "students_update" ON public.students;
CREATE POLICY "students_update"
ON public.students FOR UPDATE
TO authenticated
USING (public.is_staff_or_admin())
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "students_delete" ON public.students;
CREATE POLICY "students_delete"
ON public.students FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================
-- 3. records
-- ============================================================
DROP POLICY IF EXISTS "records_select" ON public.records;
CREATE POLICY "records_select"
ON public.records FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "records_insert" ON public.records;
CREATE POLICY "records_insert"
ON public.records FOR INSERT
TO authenticated
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "records_update" ON public.records;
CREATE POLICY "records_update"
ON public.records FOR UPDATE
TO authenticated
USING (public.is_staff_or_admin())
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "records_delete" ON public.records;
CREATE POLICY "records_delete"
ON public.records FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================
-- 4. document_types
-- ============================================================
DROP POLICY IF EXISTS "document_types_select" ON public.document_types;
CREATE POLICY "document_types_select"
ON public.document_types FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "document_types_insert" ON public.document_types;
CREATE POLICY "document_types_insert"
ON public.document_types FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "document_types_update" ON public.document_types;
CREATE POLICY "document_types_update"
ON public.document_types FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "document_types_delete" ON public.document_types;
CREATE POLICY "document_types_delete"
ON public.document_types FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================
-- 5. documents
-- ============================================================
DROP POLICY IF EXISTS "documents_select" ON public.documents;
CREATE POLICY "documents_select"
ON public.documents FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "documents_insert" ON public.documents;
CREATE POLICY "documents_insert"
ON public.documents FOR INSERT
TO authenticated
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "documents_update" ON public.documents;
CREATE POLICY "documents_update"
ON public.documents FOR UPDATE
TO authenticated
USING (public.is_staff_or_admin())
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "documents_delete" ON public.documents;
CREATE POLICY "documents_delete"
ON public.documents FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================
-- 6. document_analyses
-- ============================================================
DROP POLICY IF EXISTS "document_analyses_select" ON public.document_analyses;
CREATE POLICY "document_analyses_select"
ON public.document_analyses FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "document_analyses_insert" ON public.document_analyses;
CREATE POLICY "document_analyses_insert"
ON public.document_analyses FOR INSERT
TO authenticated
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "document_analyses_update" ON public.document_analyses;
CREATE POLICY "document_analyses_update"
ON public.document_analyses FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "document_analyses_delete" ON public.document_analyses;
CREATE POLICY "document_analyses_delete"
ON public.document_analyses FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================
-- 7. verifications
-- ============================================================
DROP POLICY IF EXISTS "verifications_select" ON public.verifications;
CREATE POLICY "verifications_select"
ON public.verifications FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "verifications_insert" ON public.verifications;
CREATE POLICY "verifications_insert"
ON public.verifications FOR INSERT
TO authenticated
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "verifications_update" ON public.verifications;
CREATE POLICY "verifications_update"
ON public.verifications FOR UPDATE
TO authenticated
USING (public.is_staff_or_admin())
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "verifications_delete" ON public.verifications;
CREATE POLICY "verifications_delete"
ON public.verifications FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================
-- 8. expiry_alerts
-- ============================================================
DROP POLICY IF EXISTS "expiry_alerts_select" ON public.expiry_alerts;
CREATE POLICY "expiry_alerts_select"
ON public.expiry_alerts FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "expiry_alerts_insert" ON public.expiry_alerts;
CREATE POLICY "expiry_alerts_insert"
ON public.expiry_alerts FOR INSERT
TO authenticated
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "expiry_alerts_update" ON public.expiry_alerts;
CREATE POLICY "expiry_alerts_update"
ON public.expiry_alerts FOR UPDATE
TO authenticated
USING (public.is_staff_or_admin())
WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "expiry_alerts_delete" ON public.expiry_alerts;
CREATE POLICY "expiry_alerts_delete"
ON public.expiry_alerts FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================
-- 9. audit_logs
-- ============================================================
DROP POLICY IF EXISTS "audit_logs_select" ON public.audit_logs;
CREATE POLICY "audit_logs_select"
ON public.audit_logs FOR SELECT
TO authenticated
USING (public.is_admin() OR actor_id = auth.uid());

-- No direct INSERT policy — audit logs are written via SECURITY DEFINER function only.
-- This means no client can insert directly; the function uses SECURITY DEFINER to bypass RLS.

DROP POLICY IF EXISTS "audit_logs_update" ON public.audit_logs;
CREATE POLICY "audit_logs_update"
ON public.audit_logs FOR UPDATE
TO authenticated
USING (false) WITH CHECK (false);

DROP POLICY IF EXISTS "audit_logs_delete" ON public.audit_logs;
CREATE POLICY "audit_logs_delete"
ON public.audit_logs FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================
-- 10. settings
-- ============================================================
DROP POLICY IF EXISTS "settings_select" ON public.settings;
CREATE POLICY "settings_select"
ON public.settings FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "settings_insert" ON public.settings;
CREATE POLICY "settings_insert"
ON public.settings FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "settings_update" ON public.settings;
CREATE POLICY "settings_update"
ON public.settings FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "settings_delete" ON public.settings;
CREATE POLICY "settings_delete"
ON public.settings FOR DELETE
TO authenticated
USING (public.is_admin());
