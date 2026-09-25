/*
# EduRecord Storage — Private Documents Bucket

## Overview
Creates a private (non-public) storage bucket named 'documents' for storing
uploaded student documents. Configures RLS policies on storage.objects so that:
- Admins and staff can upload, read, update, and delete files.
- Viewers can read (download) files but cannot upload, update, or delete.
- Unauthenticated users have no access.

## Storage Structure
- Bucket: documents (private)
- Path pattern: students/{student_id}/documents/{document_id}/{filename}

## Security
- Bucket is NOT public (public = false).
- Storage RLS policies enforce role-based access.
- Documents are accessed via signed URLs (short-lived), never public URLs.
- No anon access — only authenticated users.

## Important Notes
1. Storage policies check the user's role via the profiles table.
2. The bucket name 'documents' matches the database table name for clarity.
3. File paths include student_id for organizational clarity and potential
   future path-based policy refinement.
*/

-- Create the private documents bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'documents',
  'documents',
  false,
  52428800, -- 50MB limit
  ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp', 'image/gif',
        'text/plain', 'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- Storage RLS Policies
-- ============================================================

-- SELECT: authenticated users can read files (viewers included)
DROP POLICY IF EXISTS "documents_storage_select" ON storage.objects;
CREATE POLICY "documents_storage_select"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'documents');

-- INSERT: admin and staff can upload
DROP POLICY IF EXISTS "documents_storage_insert" ON storage.objects;
CREATE POLICY "documents_storage_insert"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'documents' AND public.is_staff_or_admin()
);

-- UPDATE: admin and staff can update
DROP POLICY IF EXISTS "documents_storage_update" ON storage.objects;
CREATE POLICY "documents_storage_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'documents' AND public.is_staff_or_admin())
WITH CHECK (
  bucket_id = 'documents' AND public.is_staff_or_admin()
);

-- DELETE: admin only can delete files
DROP POLICY IF EXISTS "documents_storage_delete" ON storage.objects;
CREATE POLICY "documents_storage_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'documents' AND public.is_admin());
