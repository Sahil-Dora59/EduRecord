import { useAuth } from '../context/AuthContext'
import { PageContainer, PageHeader } from '../components/ui/PageHeader'
import { Card, CardBody } from '../components/ui/Card'
import { ROLE_LABELS } from '../lib/constants'

export function Dashboard() {
  const { profile } = useAuth()

  return (
    <PageContainer>
      <PageHeader
        title="Dashboard"
        description="Overview of your institution's records and documents."
      />

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <Card>
          <CardBody>
            <p className="text-sm text-neutral-500 mb-1">Total Students</p>
            <p className="text-3xl font-bold text-neutral-900">—</p>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <p className="text-sm text-neutral-500 mb-1">Total Documents</p>
            <p className="text-3xl font-bold text-neutral-900">—</p>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <p className="text-sm text-neutral-500 mb-1">Pending Verification</p>
            <p className="text-3xl font-bold text-neutral-900">—</p>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <p className="text-sm text-neutral-500 mb-1">Expiring Soon</p>
            <p className="text-3xl font-bold text-neutral-900">—</p>
          </CardBody>
        </Card>
      </div>

      <Card>
        <CardBody>
          <h3 className="text-base font-semibold text-neutral-800 mb-2">Welcome to EduRecord</h3>
          <p className="text-sm text-neutral-500">
            You are signed in as <span className="font-medium text-neutral-700">{profile?.full_name}</span> ({profile ? ROLE_LABELS[profile.role] : ''}).
            Use the navigation on the left to manage students, records, and documents.
            Statistics will appear here once data is available.
          </p>
        </CardBody>
      </Card>
    </PageContainer>
  )
}
