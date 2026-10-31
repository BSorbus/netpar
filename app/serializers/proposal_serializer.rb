class ProposalSerializer < ActiveModel::Serializer
  # created_at – chwila przyjęcia zgłoszenia; Egzaminy zapisują ją jako datę zgłoszenia (ta sama data w obu systemach).
  attributes :id, :multi_app_identifier, :proposal_status_id, :not_approved_comment, :creator_id, :user_id, :fullname, :created_at


end
