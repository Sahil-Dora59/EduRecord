import { useParams } from 'react-router-dom'
import { PageContainer, PageHeader } from '../components/ui/PageHeader'
import { Card, CardBody } from '../components/ui/Card'

export function StudentDetail() {
  const { id } = useParams<{ id: string }>()

  return (
    <PageContainer>
      <PageHeader title="Student Detail" description={`Student ID: ${id}`} />
      <Card>
        <CardBody>
          <p className="text-sm text-neutral-500">
            Student detail view will be available in the next stage.
          </p>
        </CardBody>
      </Card>
    </PageContainer>
  )
}
