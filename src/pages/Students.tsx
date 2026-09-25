import { PageContainer, PageHeader } from '../components/ui/PageHeader'
import { EmptyState } from '../components/ui/Spinner'

export function Students() {
  return (
    <PageContainer>
      <PageHeader title="Students" description="Manage student records and profiles." />
      <EmptyState
        title="No students yet"
        description="Student management will be available in the next stage. For now, this page is a placeholder."
        icon={
          <svg className="h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
          </svg>
        }
      />
    </PageContainer>
  )
}
