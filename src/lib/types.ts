export type UserRole = 'admin' | 'staff' | 'viewer'

export type StudentStatus = 'active' | 'inactive' | 'graduated' | 'withdrawn'

export type RecordType = 'enrollment' | 'medical' | 'academic' | 'financial' | 'other'

export type RecordStatus = 'active' | 'archived'

export type DocumentStatus = 'pending' | 'analyzed' | 'verified' | 'rejected'

export type VerificationStatus = 'verified' | 'rejected' | 'pending'

export type AlertStatus = 'current' | 'expiring_soon' | 'expired' | 'no_expiry'

export interface Profile {
  id: string
  full_name: string
  role: UserRole
  avatar_url: string | null
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Student {
  id: string
  student_number: string
  first_name: string
  last_name: string
  email: string | null
  phone: string | null
  date_of_birth: string | null
  gender: string | null
  address: string | null
  program: string | null
  enrollment_date: string | null
  status: StudentStatus
  created_by: string | null
  created_at: string
  updated_at: string
}

export interface RecordRow {
  id: string
  student_id: string
  title: string
  record_type: RecordType
  description: string | null
  status: RecordStatus
  created_by: string | null
  created_at: string
  updated_at: string
}

export interface DocumentType {
  id: string
  name: string
  code: string
  description: string | null
  default_expiry_months: number | null
  created_at: string
}

export interface Document {
  id: string
  student_id: string
  record_id: string | null
  document_type_id: string | null
  title: string
  file_path: string
  file_name: string
  file_size: number | null
  mime_type: string | null
  status: DocumentStatus
  expiry_date: string | null
  uploaded_by: string | null
  created_at: string
  updated_at: string
}

export interface DocumentAnalysis {
  id: string
  document_id: string
  extracted_text: string | null
  summary: string | null
  key_fields: Record<string, unknown> | null
  suggested_type: string | null
  confidence_score: number | null
  flags: string[] | null
  model_used: string | null
  analyzed_by: string | null
  created_at: string
}

export interface Verification {
  id: string
  document_id: string
  status: VerificationStatus
  notes: string | null
  verified_by: string | null
  verified_at: string
}

export interface ExpiryAlert {
  id: string
  document_id: string
  expiry_date: string
  days_until_expiry: number | null
  alert_status: AlertStatus
  acknowledged: boolean
  acknowledged_by: string | null
  updated_at: string
}

export interface AuditLog {
  id: string
  actor_id: string | null
  action: string
  entity_type: string | null
  entity_id: string | null
  metadata: Record<string, unknown> | null
  created_at: string
}

export interface Setting {
  id: string
  key: string
  value: unknown
  updated_by: string | null
  updated_at: string
}

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: Profile
        Insert: Partial<Profile>
        Update: Partial<Profile>
      }
      students: {
        Row: Student
        Insert: Partial<Student>
        Update: Partial<Student>
      }
      records: {
        Row: RecordRow
        Insert: Partial<RecordRow>
        Update: Partial<RecordRow>
      }
      document_types: {
        Row: DocumentType
        Insert: Partial<DocumentType>
        Update: Partial<DocumentType>
      }
      documents: {
        Row: Document
        Insert: Partial<Document>
        Update: Partial<Document>
      }
      document_analyses: {
        Row: DocumentAnalysis
        Insert: Partial<DocumentAnalysis>
        Update: Partial<DocumentAnalysis>
      }
      verifications: {
        Row: Verification
        Insert: Partial<Verification>
        Update: Partial<Verification>
      }
      expiry_alerts: {
        Row: ExpiryAlert
        Insert: Partial<ExpiryAlert>
        Update: Partial<ExpiryAlert>
      }
      audit_logs: {
        Row: AuditLog
        Insert: Partial<AuditLog>
        Update: Partial<AuditLog>
      }
      settings: {
        Row: Setting
        Insert: Partial<Setting>
        Update: Partial<Setting>
      }
    }
  }
}
