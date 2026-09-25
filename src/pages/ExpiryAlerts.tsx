import { PageContainer, PageHeader } from '../components/ui/PageHeader'
import { EmptyState } from '../components/ui/Spinner'

export function ExpiryAlerts() {
  return (
    <PageContainer>
      <PageHeader title="Expiry Alerts" description="Track documents approaching expiration." />
      <EmptyState
        title="No expiry alerts"
        description="Expiry tracking and alerts will be available in a later stage."
        icon={
          <svg className="h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        }
      />
    </PageContainer>
  )
}
