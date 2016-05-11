# Represents examinations
# create_table "examinations", force: :cascade do |t|
#    t.integer  "division_id"
#    t.string   "examination_result",   limit: 1
#    t.integer  "exam_id"
#    t.integer  "customer_id"
#    t.text     "note",                           default: ""
#    t.string   "category",             limit: 1
#    t.integer  "user_id"
#    t.datetime "created_at",                                   null: false
#    t.datetime "updated_at",                                   null: false
#    t.integer  "certificate_id"
#    t.integer  "esod_category"
#    t.integer  "esod_matter_id"
#  end
#  add_index "examinations", ["certificate_id"], name: "index_examinations_on_certificate_id", using: :btree
#  add_index "examinations", ["customer_id"], name: "index_examinations_on_customer_id", using: :btree
#  add_index "examinations", ["division_id"], name: "index_examinations_on_division_id", using: :btree
#  add_index "examinations", ["esod_matter_id"], name: "index_examinations_on_esod_matter_id", using: :btree
#  add_index "examinations", ["exam_id"], name: "index_examinations_on_exam_id", using: :btree
#  add_index "examinations", ["user_id"], name: "index_examinations_on_user_id", using: :btree
#
require 'esodes'

class Examination < ActiveRecord::Base
  belongs_to :division
  belongs_to :exam, counter_cache: true
  belongs_to :customer
  belongs_to :user
  belongs_to :certificate 
  belongs_to :esod_matter, class_name: "Esod::Matter", foreign_key: :esod_matter_id

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, :source_type => "Examination", dependent: :destroy
  has_many :grades, dependent: :destroy  

  accepts_nested_attributes_for :grades
  validates_associated :grades

  # validates
  validates :category, presence: true, inclusion: { in: %w(L M R) }
  validates :division, presence: true
  validates :customer, presence: true
  validates :exam, presence: true
  validates :user, presence: true
  validates :esod_matter, uniqueness: { case_sensitive: false, scope: [:examination_result] }, allow_blank: true
  validates :esod_category, presence: true, inclusion: { in: Esodes::ALL_CATEGORIES_EXAMINATIONS }
  validate :check_exam_esod_category, if: "exam.present?"

  # scopes
  scope :only_category_l, -> { where(category: "L") }
  scope :only_category_m, -> { where(category: "M") }
  scope :only_category_r, -> { where(category: "R") }

  # callbacks
  #before_save :create_esod_matter, if: "esod_matter_id.blank?"
  #before_save :update_esod_matter, unless: "esod_matter_id.blank?"



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


  def create_esod_matter
    esod_matter = Esod::Matter.create!(
      nrid: nil,
      znak: nil,
      znak_sprawy_grupujacej: nil,
      symbol_jrwa: Rails.application.secrets["esod_#{category.downcase}_jrwa"],
      tytul: "#{customer.given_names} #{customer.name}, #{customer.address_city}",
      termin_realizacji: exam.date_exam,
      identyfikator_kategorii_sprawy: esod_category,
      adnotacja: "#{exam.number}",
      identyfikator_stanowiska_referenta: nil,
      czy_otwarta: true,
      data_utworzenia: nil,
      data_modyfikacji: nil,
      initialized_from_esod: false,
      netpar_user: user_id
    )
    self.esod_matter = esod_matter 
  end

  def update_esod_matter
    esod_matter = Esod::Matter.find_by(id: esod_matter_id)
    esod_matter.tytul = "#{customer.given_names} #{customer.name}, #{customer.address_city}"
    esod_matter.termin_realizacji = exam.date_exam
    esod_matter.identyfikator_kategorii_sprawy = esod_category
    esod_matter.adnotacja = "#{exam.number}"
    if esod_matter.changed?
      esod_matter.netpar_user = user_id
      esod_matter.save! 
    end
  end

  def check_exam_esod_category
    if Esodes::WITHOUT_EXAMINATIONS.include?(self.exam.esod_category) 
      errors.add(:exam_id, ' - nie można dodawać osób egzaminowanych do sesji typu: "Sesja bez egzaminu lub z egzaminem poza UKE"')
    end
  end

  def generate_certificate(gen_user_id)
    go_create_new = true

    if Esodes::RENEWING_EXAMINATIONS.include?(self.esod_category) 
      upd_certificate = Certificate.where(customer: self.customer, division: self.division, category: self.category).last
      if upd_certificate.present? && (upd_certificate.valid_thru >= Time.zone.today - 12.months)
        # Only update old certificate if find and valid_thru + 12 months < Today
        upd_certificate.esod_matter_id = self.esod_matter_id
        upd_certificate.esod_category = self.esod_category
        upd_certificate.date_of_issue = Time.zone.today
        upd_certificate.valid_thru = Certificate.default_valid_thru_date(Time.zone.today, self.division)
        upd_certificate.exam = self.exam
        upd_certificate.user_id = gen_user_id
        upd_certificate.certificate_status = "O"
        upd_certificate.save!

        self.certificate = upd_certificate
        self.save!

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
                                                      esod_matter_id: self.esod_matter_id, 
                                                      esod_category: self.esod_category, 
                                                      category: self.category)
      self.certificate = new_certificate
      self.save! 
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


end
