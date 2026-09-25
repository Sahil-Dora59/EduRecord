import { PageContainer, PageHeader } from '../../components/ui/PageHeader'
import { EmptyState } from '../../components/ui/Spinner'

export function AuditHistory() {
  return (
    <PageContainer>
      <PageHeader title="Audit History" description="View all system activity logs." />
      <EmptyState
        title="No activity logged yet"
        description="Audit history will display all system actions once users start using EduRecord."
        icon={
          <svg className="h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
          </svg>
        }
      />
    </PageContainer>
  )
}
