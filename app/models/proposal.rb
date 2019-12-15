require 'net/http'

class Proposal < ActiveRecord::Base

  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error,
    Errno::ECONNREFUSED
  ]

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

  PROPOSAL_STATUSES = [ PROPOSAL_STATUS_CREATED, 
                        PROPOSAL_STATUS_APPROVED, 
                        PROPOSAL_STATUS_NOT_APPROVED, 
                        PROPOSAL_STATUS_CLOSED, 
                        PROPOSAL_STATUS_ANNULLED,
                        PROPOSAL_STATUS_EXAMINATION_RESULT_B,
                        PROPOSAL_STATUS_EXAMINATION_RESULT_N,
                        PROPOSAL_STATUS_EXAMINATION_RESULT_O,
                        PROPOSAL_STATUS_EXAMINATION_RESULT_P,
                        PROPOSAL_STATUS_EXAMINATION_RESULT_Z ]

  CATEGORY_NAME_M = "Świadectwo służby morskiej i żeglugi śródlądowej"
  CATEGORY_NAME_R = "Świadectwo służby radioamatorskiej"


  belongs_to :proposal_status
  belongs_to :division
  belongs_to :exam_fee
  belongs_to :exam
  belongs_to :customer
  belongs_to :user

  has_one :examination, dependent: :destroy

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, :source_type => "Proposal", dependent: :destroy

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
  before_save :check_max_examinations, if: "self.new_record?"

  after_save :refresh_exam_proposals_important_count
  after_save :destroy_examination_if_annuled

  after_destroy :refresh_exam_proposals_important_count

      # params.require(:proposal).permit(:multi_app_identifier, :proposal_status_id, :category, :creator_id, :user_id, 
      #   :name, :given_names, :pesel, :birth_date, :birth_place, :phone, :email,
      #   :address_city, :address_street, :address_house, :address_number, :address_postal_code,
      #   :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code,
      #   :esod_category, :exam_id, :exam_fullname, :date_exam, :division_id, :division_fullname, 
      #   :exam_fee_id, :exam_fee_price, :face_image_blob_path, :bank_pdf_blob_path, :consent_pdf_blob_path )

  def fullname
    "#{name} #{given_names}, #{pesel}, #{exam_fullname}"
  end

  def fullname_and_id
    "#{fullname} (#{id})"
  end

  def update_rec_and_push(proposal_params)
    self.attributes = proposal_params if proposal_params.present?
    if invalid?
      return false
    else
      ActiveRecord::Base.transaction do
        begin
          egzaminy_proposal_obj = EgzaminyProposal.new(multi_app_identifier: self.multi_app_identifier, egzaminy_proposal: JSON.parse(self.to_json) )
          response = egzaminy_proposal_obj.request_update
          rescue *HTTP_ERRORS => e
            Rails.logger.error('======== API ERROR "models/proposal/update_rec_and_push - API ERROR" (1) ====')
            Rails.logger.error("#{e}")
            errors.add(:base, "#{e}")
            Rails.logger.error('=============================================================================')
            raise ActiveRecord::Rollback, "#{e}"
            false
          rescue StandardError => e
            Rails.logger.error('======== API ERROR "models/proposal/update_rec_and_push - API ERROR" (2) ====')
            Rails.logger.error("#{e}")
            errors.add(:base, "#{e}")
            Rails.logger.error('=============================================================================')
            raise ActiveRecord::Rollback, "#{e}"
            false
          else
            case response
            when Net::HTTPOK, Net::HTTPCreated
              save!
              true   # success response
            when Net::HTTPClientError, Net::HTTPInternalServerError
              Rails.logger.error('======== API ERROR "models/proposal/update_rec_and_push" (3) ================')
              Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
              errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
              Rails.logger.error('=============================================================================')
              raise ActiveRecord::Rollback, "code: #{response.code}, message: #{response.message}"
              false
            when response.class != 'String'
              Rails.logger.error('======== API ERROR "models/proposal/update_rec_and_push" (4) ================')
              Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
              errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
              Rails.logger.error('=============================================================================')
              raise ActiveRecord::Rollback, "code: #{response.code}, message: #{response.message}, body: #{response.body}"
              false
            else
              Rails.logger.error('======== API ERROR "models/proposal/update_rec_and_push" (5) ================')
              Rails.logger.error("#{response}")
              errors.add(:base, "#{response}")
              Rails.logger.error('=============================================================================')
              raise ActiveRecord::Rollback, "#{response}"
              false
            end # /case response
          end # /else         
        end # /begin
      end # /transaction
  end

  def can_edit?
    [PROPOSAL_STATUS_CREATED].include?(proposal_status_id) 
  end

  def can_edit_approved?
    [PROPOSAL_STATUS_CREATED].include?(proposal_status_id) 
  end

  def can_edit_not_approved?
    [PROPOSAL_STATUS_CREATED].include?(proposal_status_id) 
  end

  def add_to_examinations
 #   examination = self.build_examination OR
    examination = Examination.new
    examination.proposal_id = self.id
    examination.division_id = self.division_id
    examination.exam_id = self.exam_id
    examination.customer_id = self.customer_id 
    examination.category = self.category
    examination.user_id = self.user_id
    examination.esod_category = self.esod_category
#    examination.examination_result
#    examination.certificate_id

    if examination.save_and_grades_add
      examination.works.create!(trackable_url: "#{Rails.application.routes.url_helpers.examination_path(examination, category_service: examination.category.downcase)}", 
        action: :create, user_id: examination.user_id, parameters: examination.attributes.to_json)
    end
  end

  private

    def refresh_exam_proposals_important_count
      exam.refresh_proposals_important_count
    end

    def destroy_examination_if_annuled
      self.examination.destroy if self.examination.present? && self.proposal_status_id_changed?(to: PROPOSAL_STATUS_ANNULLED)
    end

    def check_max_examinations
      if (self.exam.proposals_important_count) >= (self.exam.max_examinations ||= 0) 
        errors[:base] << "Przekroczona maksymalna liczba miejsc w tej sesji egzaminacyjnej"
        false
      end    
    end

end
