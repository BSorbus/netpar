class Proposal < ActiveRecord::Base

  CATEGORY_NAME_M = "Świadectwo służby morskiej i żeglugi śródlądowej"
  CATEGORY_NAME_R = "Świadectwo służby radioamatorskiej"

  PROPOSAL_STATUS_CREATED = 1
  PROPOSAL_STATUS_APPROVED = 2
  PROPOSAL_STATUS_NOT_APPROVED = 3
  PROPOSAL_STATUS_CLOSED = 4


  belongs_to :proposal_status
  belongs_to :division
  belongs_to :exam_fee
#  belongs_to :exam, counter_cache: proposals_important_count
  belongs_to :exam
#  belongs_to :customer
  belongs_to :user
#  belongs_to :certificate 

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, :source_type => "Proposal", dependent: :destroy
#  has_many :grades, dependent: :destroy  
#  has_many :esod_matters, class_name: "Esod::Matter", foreign_key: :examination_id, dependent: :nullify

#  accepts_nested_attributes_for :grades
#  validates_associated :grades

  # validates
  validates :multi_app_identifier, presence: true
  validates :category, presence: true, inclusion: { in: %w(M R) }
  validates :proposal_status, presence: true
  validates :division, presence: true
  validates :exam_fee, presence: true
  validates :exam, presence: true
  validates :not_approved_comment, presence: true, length: { minimum: 10 }, if: "proposal_status_id == #{PROPOSAL_STATUS_NOT_APPROVED}"

#  validates :customer, presence: true
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

      # params.require(:proposal).permit(:multi_app_identifier, :proposal_status_id, :category, :creator_id, :user_id, 
      #   :name, :given_names, :pesel, :birth_date, :birth_place, :phone, :email,
      #   :address_city, :address_street, :address_house, :address_number, :address_postal_code,
      #   :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code,
      #   :esod_category, :exam_id, :exam_fullname, :date_exam, :division_id, :division_fullname, 
      #   :exam_fee_id, :exam_fee_price, :face_image_blob_path, :bank_pdf_blob_path )

  def fullname
    "#{name} #{given_names}, #{pesel}, #{exam_fullname}"
  end

  def can_or_not_approved?
    proposal_status_id == Proposal::PROPOSAL_STATUS_CREATED
  end

  private

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
