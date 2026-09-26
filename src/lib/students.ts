import { supabase } from './supabase'
import type { Student, StudentStatus } from './types'

export interface StudentFilters {
  search: string
  status: StudentStatus | 'all'
}

export async function fetchStudents(filters?: StudentFilters): Promise<Student[]> {
  let query = supabase
    .from('students')
    .select('*')
    .order('created_at', { ascending: false })

  if (filters?.status && filters.status !== 'all') {
    query = query.eq('status', filters.status)
  }

  if (filters?.search) {
    const term = filters.search.trim()
    query = query.or(
      `first_name.ilike.%${term}%,last_name.ilike.%${term}%,student_number.ilike.%${term}%,email.ilike.%${term}%`
    )
  }

  const { data, error } = await query
  if (error) throw error
  return data ?? []
}

export async function fetchStudentById(id: string): Promise<Student | null> {
  const { data, error } = await supabase
    .from('students')
    .select('*')
    .eq('id', id)
    .maybeSingle()

  if (error) throw error
  return data
}

export interface StudentInput {
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
}

export async function createStudent(input: StudentInput): Promise<Student> {
  const { data, error } = await supabase
    .from('students')
    .insert(input)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function updateStudent(id: string, input: Partial<StudentInput>): Promise<Student> {
  const { data, error } = await supabase
    .from('students')
    .update(input)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function deleteStudent(id: string): Promise<void> {
  const { error } = await supabase.from('students').delete().eq('id', id)
  if (error) throw error
}

export async function checkStudentNumberUnique(
  studentNumber: string,
  excludeId?: string
): Promise<boolean> {
  let query = supabase
    .from('students')
    .select('id')
    .eq('student_number', studentNumber)

  if (excludeId) {
    query = query.neq('id', excludeId)
  }

  const { data, error } = await query.maybeSingle()
  if (error) throw error
  return data === null
}
