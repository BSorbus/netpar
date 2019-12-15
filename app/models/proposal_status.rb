class ProposalStatus < ActiveRecord::Base

  PROPOSAL_STATUS_CREATED = 1
  PROPOSAL_STATUS_APPROVED = 2
  PROPOSAL_STATUS_NOT_APPROVED = 3
  PROPOSAL_STATUS_CLOSED = 4
  PROPOSAL_STATUS_ANNULLED = 5
  PROPOSAL_STATUS_EXAMINATION_RESULT_B = 6  # "Negatywny bez prawa do poprawki" 
  PROPOSAL_STATUS_EXAMINATION_RESULT_N = 7  # "Negatywny z prawem do poprawki" 
  PROPOSAL_STATUS_EXAMINATION_RESULT_O = 8  # "Nieobecny" 
  PROPOSAL_STATUS_EXAMINATION_RESULT_P = 9  # "Pozytywny" 
  PROPOSAL_STATUS_EXAMINATION_RESULT_Z = 10 # "Zmiana terminu" 

  PROPOSAL_IMPORTANT_STATUSES = [ PROPOSAL_STATUS_CREATED, 
                                  PROPOSAL_STATUS_APPROVED, 
                                  PROPOSAL_STATUS_CLOSED, 
                                  PROPOSAL_STATUS_EXAMINATION_RESULT_B,
                                  PROPOSAL_STATUS_EXAMINATION_RESULT_N,
                                  PROPOSAL_STATUS_EXAMINATION_RESULT_O,
                                  PROPOSAL_STATUS_EXAMINATION_RESULT_P,
                                  PROPOSAL_STATUS_EXAMINATION_RESULT_Z ]

  # relations
  has_many :proposals, dependent: :nullify

  # validates
  validates :name, presence: true,
                    length: { in: 1..100 },
                    uniqueness: { case_sensitive: false }

  # scope
  scope :status_can_change, -> { where(id: [PROPOSAL_STATUS_CREATED, PROPOSAL_STATUS_APPROVED, PROPOSAL_STATUS_NOT_APPROVED]) }

end
