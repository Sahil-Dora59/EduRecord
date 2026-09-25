/*
# EduRecord Schema Part 2 — Analyses, Verifications, Expiry Alerts, Audit Logs, Settings

## Overview
Creates the remaining five tables for EduRecord: document analyses (AI results),
verifications (verification history), expiry alerts, audit logs, and system settings.
Includes enums, foreign keys, indexes, and RLS.

## New Tables

### 6. document_analyses
- AI analysis results (one-to-many: re-analyzable).
- `id` (uuid, PK)
- `document_id` (uuid, FK → documents.id, ON DELETE CASCADE)
- `extracted_text` (text, nullable) — OCR/extracted content
- `summary` (text, nullable) — AI-generated summary
- `key_fields` (jsonb, nullable) — structured key-value pairs
- `suggested_type` (text, nullable)
- `confidence_score` (numeric, nullable) — 0.0 to 1.0
- `flags` (jsonb, nullable) — array of issue flags
- `model_used` (text, nullable)
- `analyzed_by` (uuid, FK → profiles.id, ON DELETE SET NULL)
- `created_at` (timestamptz, default now())

### 7. verifications
- Verification history (one-to-many: re-verification trail).
- `id` (uuid, PK)
- `document_id` (uuid, FK → documents.id, ON DELETE CASCADE)
- `status` (text, not null) — CHECK: verified/rejected/pending
- `notes` (text, nullable)
- `verified_by` (uuid, FK → profiles.id, ON DELETE SET NULL)
- `verified_at` (timestamptz, default now())

### 8. expiry_alerts
- One row per document with an expiry date.
- `id` (uuid, PK)
- `document_id` (uuid, FK → documents.id, ON DELETE CASCADE, UNIQUE)
- `expiry_date` (date, not null)
- `days_until_expiry` (int, nullable)
- `alert_status` (text, not null, default 'current') — CHECK: current/expiring_soon/expired/no_expiry
- `acknowledged` (boolean, default false)
- `acknowledged_by` (uuid, FK → profiles.id, ON DELETE SET NULL)
- `updated_at` (timestamptz, default now())

### 9. audit_logs
- Activity history.
- `id` (uuid, PK)
- `actor_id` (uuid, FK → profiles.id, ON DELETE SET NULL)
- `action` (text, not null)
- `entity_type` (text, nullable)
- `entity_id` (uuid, nullable)
- `metadata` (jsonb, nullable)
- `created_at` (timestamptz, default now())

### 10. settings
- System-level configuration.
- `id` (uuid, PK)
- `key` (text, not null, UNIQUE)
- `value` (jsonb, nullable)
- `updated_by` (uuid, FK → profiles.id, ON DELETE SET NULL)
- `updated_at` (timestamptz, default now())

## Indexes
- document_analyses: document_id
- verifications: document_id, status
- expiry_alerts: document_id (unique), alert_status, expiry_date
- audit_logs: actor_id, created_at, entity_type
- settings: key (unique, already via constraint)

## Security
- RLS enabled on ALL tables.

## Important Notes
1. expiry_alerts has a UNIQUE constraint on document_id (one alert per document).
2. audit_logs.actor_id is nullable to survive user deletion (ON DELETE SET NULL).
3. confidence_score uses numeric(3,2) to store 0.00–1.00.
*/

-- ============================================================
-- 6. document_analyses
-- ============================================================
CREATE TABLE IF NOT EXISTS public.document_analyses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid NOT NULL REFERENCES public.documents(id) ON DELETE CASCADE,
  extracted_text text,
  summary text,
  key_fields jsonb,
  suggested_type text,
  confidence_score numeric(3,2),
  flags jsonb,
  model_used text,
  analyzed_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_document_analyses_document_id ON public.document_analyses(document_id);

-- ============================================================
-- 7. verifications
-- ============================================================
CREATE TABLE IF NOT EXISTS public.verifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid NOT NULL REFERENCES public.documents(id) ON DELETE CASCADE,
  status text NOT NULL CHECK (status IN ('verified', 'rejected', 'pending')),
  notes text,
  verified_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  verified_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_verifications_document_id ON public.verifications(document_id);
CREATE INDEX IF NOT EXISTS idx_verifications_status ON public.verifications(status);

-- ============================================================
-- 8. expiry_alerts
-- ============================================================
CREATE TABLE IF NOT EXISTS public.expiry_alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid NOT NULL UNIQUE REFERENCES public.documents(id) ON DELETE CASCADE,
  expiry_date date NOT NULL,
  days_until_expiry int,
  alert_status text NOT NULL DEFAULT 'current' CHECK (alert_status IN ('current', 'expiring_soon', 'expired', 'no_expiry')),
  acknowledged boolean NOT NULL DEFAULT false,
  acknowledged_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_expiry_alerts_alert_status ON public.expiry_alerts(alert_status);
CREATE INDEX IF NOT EXISTS idx_expiry_alerts_expiry_date ON public.expiry_alerts(expiry_date);

-- ============================================================
-- 9. audit_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  action text NOT NULL,
  entity_type text,
  entity_id uuid,
  metadata jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_actor_id ON public.audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity_type ON public.audit_logs(entity_type);

-- ============================================================
-- 10. settings
-- ============================================================
CREATE TABLE IF NOT EXISTS public.settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE,
  value jsonb,
  updated_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- Enable RLS on all tables
-- ============================================================
ALTER TABLE public.document_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expiry_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
