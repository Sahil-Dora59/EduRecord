import { PageContainer } from '../components/ui/PageHeader'

export function NotFound() {
  return (
    <PageContainer>
      <div className="flex flex-col items-center justify-center py-20 text-center">
        <p className="text-6xl font-bold text-neutral-200 mb-4">404</p>
        <h1 className="text-xl font-semibold text-neutral-800 mb-2">Page not found</h1>
        <p className="text-sm text-neutral-500">The page you're looking for doesn't exist.</p>
      </div>
    </PageContainer>
  )
}
