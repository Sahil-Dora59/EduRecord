import { useParams } from 'react-router-dom'
import { PageContainer, PageHeader } from '../components/ui/PageHeader'
import { Card, CardBody } from '../components/ui/Card'

export function DocumentDetail() {
  const { id } = useParams<{ id: string }>()

  return (
    <PageContainer>
      <PageHeader title="Document Detail" description={`Document ID: ${id}`} />
      <Card>
        <CardBody>
          <p className="text-sm text-neutral-500">
            Document detail view, AI analysis, and verification will be available in later stages.
          </p>
        </CardBody>
      </Card>
    </PageContainer>
  )
}
