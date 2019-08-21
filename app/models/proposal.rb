#require 'esodes'

class Proposal < ActiveRecord::Base

  PROPOSAL_CREATED = 1
  PROPOSAL_APPROVED = 2
  PROPOSAL_NOT_APPROVED = 3
  PROPOSAL_PAYED = 4
  PROPOSAL_CLOSED = 5

  belongs_to :division
  belongs_to :exam_fee
#  belongs_to :exam, counter_cache: proposals_important_count
  belongs_to :exam
#  belongs_to :customer
#  belongs_to :user
#  belongs_to :certificate 

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, :source_type => "Proposal", dependent: :destroy
#  has_many :grades, dependent: :destroy  
#  has_many :esod_matters, class_name: "Esod::Matter", foreign_key: :examination_id, dependent: :nullify

#  accepts_nested_attributes_for :grades
#  validates_associated :grades

  # validates
  #validates :multi_app_identifier, presence: true
  #validates :category, presence: true, inclusion: { in: %w(M R) }
  #validates :division, presence: true
  #validates :exam_fee, presence: true
#  validates :customer, presence: true
  #validates :exam, presence: true
#  validates :user, presence: true
#  validates :esod_matter, uniqueness: { case_sensitive: false, scope: [:examination_result] }, allow_blank: true
#  validates :esod_category, presence: true, inclusion: { in: Esodes::ALL_CATEGORIES_EXAMINATIONS }
#  validate :check_exam_esod_category, if: "exam.present?"

  # scopes
  scope :only_category_l, -> { where(category: "L") }
  scope :only_category_m, -> { where(category: "M") }
  scope :only_category_r, -> { where(category: "R") }

  # callbacks
  before_save :check_max_examinations, on: :create

  after_save :refresh_exam_proposals_important_count
  after_destroy :refresh_exam_proposals_important_count

  def refresh_exam_proposals_important_count
    exam.refresh_proposals_important_count
  end


  def check_max_examinations
    if (self.exam.proposals_important_count + self.exam.examinations_count) >= (self.exam.max_examinations ||= 0) 
      errors[:base] << "Przekroczona maksymalna liczba miejsc w tej sesji egzaminacyjnej"
      false
    end    
  end



end