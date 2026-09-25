import { PageContainer, PageHeader } from '../components/ui/PageHeader'
import { EmptyState } from '../components/ui/Spinner'

export function Search() {
  return (
    <PageContainer>
      <PageHeader title="Smart Search" description="Search across students, records, and documents." />
      <EmptyState
        title="Smart Search coming soon"
        description="AI-powered search across all records and documents will be available in a later stage."
        icon={
          <svg className="h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        }
      />
    </PageContainer>
  )
}
