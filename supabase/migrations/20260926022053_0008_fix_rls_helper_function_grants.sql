/*
# Fix: Re-grant EXECUTE on RLS helper functions to authenticated

## Root Cause
Migration 0007 revoked EXECUTE on is_admin() and is_staff_or_admin()
from the authenticated role. These functions are called inside RLS
policy expressions on profiles, students, records, documents, and
most other tables. Without EXECUTE permission, any query against a
table whose RLS policy references these functions fails with a
permission error, which Supabase Auth surfaces as "Database error
querying schema".

## Fix
Re-grant EXECUTE on is_admin() and is_staff_or_admin() to authenticated.
These are safe to call — they are read-only boolean checks that query
the profiles table to determine the caller's role. They cannot modify
data and do not expose sensitive information.

handle_new_user remains revoked (it is a trigger function, not called
via RPC or RLS policies).

## Security Impact
Minimal. These functions return a boolean only. They are already
SECURITY DEFINER with SET search_path = public, so they run with the
owner's privileges and cannot be abused for privilege escalation.
*/

GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_staff_or_admin() TO authenticated;
