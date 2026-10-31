# Pełny opis rodzaju świadectwa (GET /api/v1/divisions/:id): dane rodzaju jak w liście oraz przedmioty egzaminu.
class Api::V1::DivisionWithSubjectsSerializer < Api::V1::DivisionSerializer
  has_many :subjects, serializer: Api::V1::SubjectSerializer

  def subjects
    object.subjects.order(:item, :id)
  end
end
