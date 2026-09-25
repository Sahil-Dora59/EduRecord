import { PageContainer, PageHeader } from '../components/ui/PageHeader'
import { EmptyState } from '../components/ui/Spinner'

export function Verification() {
  return (
    <PageContainer>
      <PageHeader title="Verification Queue" description="Review and verify pending documents." />
      <EmptyState
        title="No documents pending verification"
        description="Document verification will be available in a later stage."
        icon={
          <svg className="h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.948 11.948 0 0112 3c-2.8 0-5.486.684-7.838 1.9A2 2 0 002 6.382v7.236a2 2 0 00.162.984A11.948 11.948 0 0112 21c2.8 0 5.486-.684 7.838-1.9a2 2 0 00.162-.984V6.382a2 2 0 00-.162-.984z" />
          </svg>
        }
      />
    </PageContainer>
  )
}
