require 'esodes'

class Examination < ActiveRecord::Base
  belongs_to :division
  belongs_to :exam, counter_cache: true
  belongs_to :customer
  belongs_to :user
  belongs_to :certificate 
  belongs_to :proposal 

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, :source_type => "Examination", dependent: :destroy
  has_many :grades, dependent: :destroy  
  has_many :esod_matters, class_name: "Esod::Matter", foreign_key: :examination_id, dependent: :nullify

  accepts_nested_attributes_for :grades
  validates_associated :grades

  # validates
  validates :category, presence: true, inclusion: { in: %w(L M R) }
  validates :division, presence: true
  validates :customer, presence: true
  validates :exam, presence: true
  validates :user, presence: true
#  validates :esod_matter, uniqueness: { case_sensitive: false, scope: [:examination_result] }, allow_blank: true
  validates :esod_category, presence: true, inclusion: { in: Esodes::ALL_CATEGORIES_EXAMINATIONS }
  validate :check_exam_esod_category, if: "exam.present?"

  # scopes
  scope :only_category_l, -> { where(category: "L") }
  scope :only_category_m, -> { where(category: "M") }
  scope :only_category_r, -> { where(category: "R") }

  # callbacks
  after_save :close_proposal_if_change_examination_result, if: "proposal_id.present?", unless: "examination_result.blank?"


  def fullname
    "#{customer.fullname}  =>  #{exam.fullname}"
  end

  def fullname_and_id
    "#{customer.fullname}  =>  #{exam.fullname} (#{id})"
  end

  def esod_category_name
    Esodes::esod_matter_iks_name(esod_category)
  end

  def examination_result_name
    case examination_result
    when 'B'
      'Negatywny bez prawa do poprawki'
    when 'N'
      'Negatywny z prawem do poprawki'
    when 'O'
      'Nieobecny'
    when 'P'
      'Pozytywny'
    when 'Z'
      'Zmiana terminu'
    when '', nil
      ''
    else
      'Error !'
    end  
  end

  def flat_all_esod_matters
    self.esod_matters.order(:id).flat_map {|row| row.znak_with_padlock }.join(' <br>').html_safe
  end

  def is_in_proposals_with_status_created
    if self.customer_id.present?
      pesel = self.customer.pesel
      if pesel.present?
        Proposal.find_by(exam_id: self.exam_id, pesel: pesel, proposal_status_id: Proposal::PROPOSAL_STATUS_CREATED)
      else
        email = self.customer.email
        if email.present?
          Proposal.find_by(exam_id: self.exam_id, email: email.downcase, proposal_status_id: Proposal::PROPOSAL_STATUS_CREATED)
        else
          name = self.customer.name.downcase
          given_names = self.customer.given_names.downcase
          birth_date = self.customer.birth_date
          Proposal.find_by(["exam_id = :exam_id AND birth_date = :birth_date AND LOWER(name) = :name AND LOWER(given_names) = :given_names AND proposal_status_id = :proposal_status_id", 
            {exam_id: self.exam_id, birth_date: birth_date, name: name, given_names: given_names, proposal_status_id: Proposal::PROPOSAL_STATUS_CREATED}])
        end
      end
    end
  end

  def check_exam_esod_category
    if Esodes::WITHOUT_EXAMINATIONS.include?(self.exam.esod_category) 
      errors.add(:exam_id, ' - nie można dodawać osób egzaminowanych do sesji typu: "Sesja bez egzaminu lub z egzaminem poza UKE"')
    end
  end

  def save_and_grades_add
    ActiveRecord::Base.transaction do
      save_result = self.save
      if save_result
        self.division.subjects.where("'?' = ANY (esod_categories)", self.esod_category).order(:item).each do |subject|
          if Esodes::ORDINARY_EXAMINATIONS.include?(self.esod_category) #egzamin zwykły/zwykły PW 
            self.grades.create!(user: self.user, subject: subject)
          else #jesli to egzamin poprawkowy/odnowienie z egzaminem, poprawkowy
            # poszukaj ocen z oceną negatywną
            customer_last_examination = Examination.where(customer: self.customer, division: self.division, examination_result: 'N').last # Negatywny z prawem do poprawki
            if customer_last_examination.present?
              self.grades.create!(user: self.user, subject: subject) if customer_last_examination.grades.where(grade_result: 'N', subject: subject).any?
            else
              self.grades.create!(user: self.user, subject: subject)
            end
          end
        end
        proposal_files_add
      end
      return save_result
    end
  end

  def proposal_files_add
    if self.proposal.present?

      consent_file_url = "#{Rails.application.secrets[:egzaminy_host]}#{proposal.consent_pdf_blob_path}" if proposal.consent_pdf_blob_path.present?
      face_file_url    = "#{Rails.application.secrets[:egzaminy_host]}#{proposal.face_image_blob_path}"  if proposal.face_image_blob_path.present?
      bank_file_url    = "#{Rails.application.secrets[:egzaminy_host]}#{proposal.bank_pdf_blob_path}"    if proposal.bank_pdf_blob_path.present?

      self.file_to_documents_attach(consent_file_url) if consent_file_url.present?
      self.file_to_documents_attach(face_file_url) if face_file_url.present?
      self.file_to_documents_attach(bank_file_url) if bank_file_url.present?

    end
  end

  def file_to_documents_attach(file_url)
    filename = File.basename(URI.parse( file_url ).path)

    doc = self.documents.new  
    doc.fileattach = open(file_url)
    doc.fileattach_filename = filename
    doc.save
  end


  def generate_certificate(gen_user_id)
    go_create_new = true

    if Esodes::RENEWING_EXAMINATIONS.include?(self.esod_category) 
      upd_certificate = Certificate.where(customer: self.customer, division: self.division, category: self.category).last
      if upd_certificate.present? && (upd_certificate.valid_thru >= Time.zone.today - 12.months)
        # Only update old certificate if find and valid_thru + 12 months < Today
        upd_certificate.esod_category = self.esod_category
        upd_certificate.date_of_issue = Time.zone.today
        upd_certificate.valid_thru = Certificate.default_valid_thru_date(Time.zone.today, self.division)
        upd_certificate.exam = self.exam
        upd_certificate.user_id = gen_user_id
        upd_certificate.save!

        self.certificate = upd_certificate
        self.save!

        # coś tu jest nie halo TODO
        #self.esod_matters.last.update(certificate: upd_certificate)
        self.esod_matters.last.update_columns(certificate_id: upd_certificate.id)

        upd_certificate.works.create( trackable_url: "#{Rails.application.routes.url_helpers.certificate_path(upd_certificate, category_service: new_certificate.category.downcase)}", 
          action: :update_certificate, user_id: gen_user_id, 
          parameters: upd_certificate.to_json(except: [:exam_id, :division_id, :customer_id, :user_id], 
                                              include: {
                                                exam: {only: [:id, :number, :date_exam]},
                                                division: {only: [:id, :name]},
                                                customer: {only: [:id, :name, :given_names, :birth_date]},
                                                user: {only: [:id, :name, :email]}
                                                }
                                              ) )
        go_create_new = false
      end       
    end

    if go_create_new
      new_certificate = self.exam.certificates.create(number: Certificate.next_certificate_number(self.category, self.division), 
                                                      date_of_issue: Time.zone.today,
                                                      valid_thru: Certificate.default_valid_thru_date(Time.zone.today, self.division),
                                                      user_id: gen_user_id, 
                                                      customer: self.customer, 
                                                      division: self.division, 
                                                      esod_category: self.esod_category, 
                                                      category: self.category)
      self.certificate = new_certificate
      self.save! 

      # coś tu jest nie halo TODO
      #self.esod_matters.last.update(certificate: new_certificate)
      self.esod_matters.last.update_columns(certificate_id: new_certificate.id)

      new_certificate.works.create( trackable_url: "#{Rails.application.routes.url_helpers.certificate_path(new_certificate, category_service: new_certificate.category.downcase)}", 
        action: :generate_certificate, user_id: gen_user_id, 
        parameters: new_certificate.to_json(except: [:exam_id, :division_id, :customer_id, :user_id], 
                                            include: {
                                              exam: {only: [:id, :number, :date_exam]},
                                              division: {only: [:id, :name]},
                                              customer: {only: [:id, :name, :given_names, :birth_date]},
                                              user: {only: [:id, :name, :email]}
                                              }
                                            ) )
    end
  end


  def close_proposal_if_change_examination_result
    if self.examination_result_changed?

      self.proposal.user_id = self.user_id
      case self.examination_result
      when 'B'
        self.proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_EXAMINATION_RESULT_B
      when 'N'
        self.proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_EXAMINATION_RESULT_N
      when 'O'
        self.proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_EXAMINATION_RESULT_O
      when 'P'
        self.proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_EXAMINATION_RESULT_P
      when 'Z'
        self.proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_EXAMINATION_RESULT_Z
      else
        raise "examination.examination_result bad value"
      end  

      if self.proposal.update_rec_and_push(nil)
        self.proposal.works.create!(trackable_url: "#{Rails.application.routes.url_helpers.proposal_path(self.proposal, category_service: self.category.downcase)}", 
          action: :closed, user_id: self.user_id, 
          parameters: self.proposal.to_json(except: {proposal: [:id, :proposal_status_id, :user_id]}, 
                  include: { 
                    exam: {
                      only: [:id, :number, :date_exam, :place_exam] },
                    proposal_status: {
                      only: [:id, :name] },
                    user: {
                      only: [:id, :name, :email] } 
                          }))
      end
    end
  end

end
