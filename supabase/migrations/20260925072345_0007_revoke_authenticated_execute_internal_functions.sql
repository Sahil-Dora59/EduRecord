/*
# EduRecord Security Hardening Part 2 — Revoke authenticated EXECUTE on internal functions

## Overview
Fixes remaining security advisor warnings for functions that should not be
directly callable via the Supabase RPC API by authenticated users.

## Changes
- REVOKE EXECUTE ON handle_new_user FROM authenticated — trigger function, not RPC
- REVOKE EXECUTE ON is_admin FROM authenticated — RLS helper, not for direct RPC
- REVOKE EXECUTE ON is_staff_or_admin FROM authenticated — RLS helper, not for direct RPC

## Important Notes
1. RLS policies that reference is_admin()/is_staff_or_admin() still work because
   policy evaluation calls functions internally, not through the RPC API.
2. handle_new_user is a trigger — it fires on INSERT to auth.users, not via RPC.
3. log_action, set_user_role, set_user_active remain callable by authenticated
   (intentional — they have internal admin authorization checks).
*/

REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.is_staff_or_admin() FROM authenticated;
