import type { ReactNode } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'
import { FullPageSpinner } from '../ui/Spinner'
import type { UserRole } from '../../lib/types'

interface ProtectedRouteProps {
  children: ReactNode
  roles?: UserRole[]
}

export function ProtectedRoute({ children, roles }: ProtectedRouteProps) {
  const { session, profile, loading } = useAuth()

  if (loading) {
    return <FullPageSpinner message="Loading..." />
  }

  if (!session) {
    return <Navigate to="/login" replace />
  }

  if (profile && !profile.is_active) {
    return <Navigate to="/login" replace />
  }

  if (roles && profile && !roles.includes(profile.role)) {
    return <Navigate to="/" replace />
  }

  return <>{children}</>
}
