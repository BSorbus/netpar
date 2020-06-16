class ProposalSerializer < ActiveModel::Serializer
  attributes :id, :multi_app_identifier, :proposal_status_id, :not_approved_comment, :creator_id, :user_id, :fullname


end

