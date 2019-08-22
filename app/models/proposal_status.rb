class ProposalStatus < ActiveRecord::Base

  PROPOSAL_STATUS_CREATED = 1
  PROPOSAL_STATUS_APPROVED = 2
  PROPOSAL_STATUS_NOT_APPROVED = 3
  PROPOSAL_STATUS_PAYED = 4
  PROPOSAL_STATUS_CLOSED = 5

  # relations
  has_many :proposals, dependent: :nullify

  # validates
  validates :name, presence: true,
                    length: { in: 1..100 },
                    uniqueness: { case_sensitive: false }

  # scope
  scope :status_can_change, -> { where(id: [PROPOSAL_STATUS_CREATED, PROPOSAL_STATUS_APPROVED, PROPOSAL_STATUS_NOT_APPROVED]) }

end
