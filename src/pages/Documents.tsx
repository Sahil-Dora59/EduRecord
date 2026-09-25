import { PageContainer, PageHeader } from '../components/ui/PageHeader'
import { EmptyState } from '../components/ui/Spinner'

export function Documents() {
  return (
    <PageContainer>
      <PageHeader title="Documents" description="Browse and manage uploaded documents." />
      <EmptyState
        title="No documents yet"
        description="Document management will be available in the next stage."
        icon={
          <svg className="h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
          </svg>
        }
      />
    </PageContainer>
  )
}
