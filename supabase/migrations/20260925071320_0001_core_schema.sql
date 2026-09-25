/*
# EduRecord Core Schema — Profiles, Students, Records, Document Types, Documents

## Overview
Creates the foundational tables for EduRecord, an AI Document & Record Management System.
This migration establishes user profiles (extending auth.users), students, records,
document types, and documents with all enums, foreign keys, indexes, and constraints.

## New Tables

### 1. profiles
- Extends auth.users with application-specific data.
- `id` (uuid, PK, FK → auth.users.id, ON DELETE CASCADE)
- `full_name` (text, not null)
- `role` (text, not null, default 'viewer') — CHECK constraint limits to admin/staff/viewer
- `avatar_url` (text, nullable)
- `is_active` (boolean, default true)
- `created_at` (timestamptz, default now())
- `updated_at` (timestamptz, default now())

### 2. students
- `id` (uuid, PK, default gen_random_uuid())
- `student_number` (text, not null, UNIQUE)
- `first_name` (text, not null)
- `last_name` (text, not null)
- `email` (text, nullable)
- `phone` (text, nullable)
- `date_of_birth` (date, nullable)
- `gender` (text, nullable)
- `address` (text, nullable)
- `program` (text, nullable)
- `enrollment_date` (date, nullable)
- `status` (text, not null, default 'active') — CHECK: active/inactive/graduated/withdrawn
- `created_by` (uuid, FK → profiles.id, ON DELETE SET NULL)
- `created_at` (timestamptz, default now())
- `updated_at` (timestamptz, default now())

### 3. records
- Logical grouping of documents tied to a student.
- `id` (uuid, PK)
- `student_id` (uuid, FK → students.id, ON DELETE CASCADE)
- `title` (text, not null)
- `record_type` (text, not null) — CHECK: enrollment/medical/academic/financial/other
- `description` (text, nullable)
- `status` (text, not null, default 'active') — CHECK: active/archived
- `created_by` (uuid, FK → profiles.id, ON DELETE SET NULL)
- `created_at` (timestamptz, default now())
- `updated_at` (timestamptz, default now())

### 4. document_types
- Taxonomy of document categories.
- `id` (uuid, PK)
- `name` (text, not null, UNIQUE)
- `code` (text, not null, UNIQUE)
- `description` (text, nullable)
- `default_expiry_months` (int, nullable)
- `created_at` (timestamptz, default now())

### 5. documents
- Uploaded files tied to students and optionally to records.
- `id` (uuid, PK)
- `student_id` (uuid, FK → students.id, ON DELETE CASCADE)
- `record_id` (uuid, FK → records.id, ON DELETE SET NULL, nullable)
- `document_type_id` (uuid, FK → document_types.id, ON DELETE SET NULL, nullable)
- `title` (text, not null)
- `file_path` (text, not null) — storage path
- `file_name` (text, not null) — original filename
- `file_size` (bigint, nullable)
- `mime_type` (text, nullable)
- `status` (text, not null, default 'pending') — CHECK: pending/analyzed/verified/rejected
- `expiry_date` (date, nullable)
- `uploaded_by` (uuid, FK → profiles.id, ON DELETE SET NULL)
- `created_at` (timestamptz, default now())
- `updated_at` (timestamptz, default now())

## Indexes
- students: student_number (unique, already via constraint), status
- records: student_id, status
- documents: student_id, record_id, document_type_id, status, expiry_date

## Security
- RLS enabled on ALL tables (policies added in a separate migration).
- No table is publicly readable.

## Important Notes
1. All primary keys use uuid with gen_random_uuid() default.
2. All timestamps use timestamptz with now() default.
3. ON DELETE behavior is deliberate: CASCADE for student-owned data, SET NULL for user references.
4. Role column defaults to 'viewer' but is controlled by SECURITY DEFINER functions (later migration).
*/

-- Enable pgcrypto for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- 1. profiles
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  role text NOT NULL DEFAULT 'viewer' CHECK (role IN ('admin', 'staff', 'viewer')),
  avatar_url text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- 2. students
-- ============================================================
CREATE TABLE IF NOT EXISTS public.students (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_number text NOT NULL UNIQUE,
  first_name text NOT NULL,
  last_name text NOT NULL,
  email text,
  phone text,
  date_of_birth date,
  gender text,
  address text,
  program text,
  enrollment_date date,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'graduated', 'withdrawn')),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_students_status ON public.students(status);

-- ============================================================
-- 3. records
-- ============================================================
CREATE TABLE IF NOT EXISTS public.records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  title text NOT NULL,
  record_type text NOT NULL CHECK (record_type IN ('enrollment', 'medical', 'academic', 'financial', 'other')),
  description text,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_records_student_id ON public.records(student_id);
CREATE INDEX IF NOT EXISTS idx_records_status ON public.records(status);

-- ============================================================
-- 4. document_types
-- ============================================================
CREATE TABLE IF NOT EXISTS public.document_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  code text NOT NULL UNIQUE,
  description text,
  default_expiry_months int,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- 5. documents
-- ============================================================
CREATE TABLE IF NOT EXISTS public.documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  record_id uuid REFERENCES public.records(id) ON DELETE SET NULL,
  document_type_id uuid REFERENCES public.document_types(id) ON DELETE SET NULL,
  title text NOT NULL,
  file_path text NOT NULL,
  file_name text NOT NULL,
  file_size bigint,
  mime_type text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'analyzed', 'verified', 'rejected')),
  expiry_date date,
  uploaded_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_documents_student_id ON public.documents(student_id);
CREATE INDEX IF NOT EXISTS idx_documents_record_id ON public.documents(record_id);
CREATE INDEX IF NOT EXISTS idx_documents_document_type_id ON public.documents(document_type_id);
CREATE INDEX IF NOT EXISTS idx_documents_status ON public.documents(status);
CREATE INDEX IF NOT EXISTS idx_documents_expiry_date ON public.documents(expiry_date);

-- ============================================================
-- Enable RLS on all tables
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.document_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
