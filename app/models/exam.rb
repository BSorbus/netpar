# Represents exams
#  create_table "exams", force: :cascade do |t|
#    t.string   "number",     limit: 30, default: "",  null: false
#    t.date     "date_exam"
#    t.string   "place_exam", limit: 50, default: ""
#    t.string   "chairman",   limit: 50, default: ""
#    t.string   "secretary",  limit: 50, default: ""
#    t.string   "category",   limit: 1,  default: "R", null: false
#    t.text     "note",                  default: ""
#    t.integer  "user_id"
#    t.datetime "created_at",                          null: false
#    t.datetime "updated_at",                          null: false
#    t.integer  "examinations_count",            default: 0
#    t.integer  "certificates_count",            default: 0
#    t.integer  "esod_matter_id"
#    t.integer  "esod_category"
#  end
#  add_index "exams", ["category"], name: "index_exams_on_category", using: :btree
#  add_index "exams", ["date_exam"], name: "index_exams_on_date_exam", using: :btree
#  add_index "exams", ["esod_matter_id"], name: "index_exams_on_esod_matter_id", using: :btree
#  add_index "exams", ["number", "category"], name: "index_exams_on_number_and_category", unique: true, using: :btree
#  add_index "exams", ["user_id"], name: "index_exams_on_user_id", using: :btree
#
require 'esodes'

class Exam < ActiveRecord::Base
  belongs_to :user
  belongs_to :esod_matter, class_name: "Esod::Matter", foreign_key: :esod_matter_id#, dependent: :delete
 
  has_many :certificates, dependent: :destroy
  has_many :examinations, dependent: :destroy
  has_many :examiners, inverse_of: :exam, dependent: :destroy  

  accepts_nested_attributes_for :examiners,
                                reject_if: proc { |attributes| attributes['name'].blank? },
                                allow_destroy: true
  validates_associated :examiners

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, dependent: :destroy
  # has_many :customers, through: :certificates
  # has_many :customers, through: :examinations
  has_many :certificate_customers, through: :certificates, source: :customer
  has_many :examination_customers, through: :examinations, source: :customer

  # validates
  validates :esod_category, presence: true, inclusion: { in: Esodes::ALL_CATEGORIES_EXAMS }
  validates :number, presence: true,
                    length: { in: 1..30 },
                    :uniqueness => { :case_sensitive => false, :scope => [:category] }

  validates :date_exam, presence: true
  validates :place_exam, presence: true,
                    length: { in: 1..50 }
  validates :category, presence: true, inclusion: { in: %w(L M R) }
  validates :user, presence: true

  validates :esod_matter, uniqueness: { case_sensitive: false }, allow_blank: true
  validate :exam_has_examinations, on: :update, if: "esod_category != esod_category_was"

  # scopes
	scope :only_category_l, -> { where(category: "L") }
	scope :only_category_m, -> { where(category: "M") }
	scope :only_category_r, -> { where(category: "R") }

  # callbacks
  before_save { self.number = number.upcase }
  #before_save :create_esod_matter, if: "esod_matter_id.blank?"
  #before_save :update_esod_matter, unless: "esod_matter_id.blank?"

  before_destroy :exam_has_links, prepend: true



  def fullname
    "#{number}, z dn. #{date_exam}, #{place_exam}"
  end

  def fullname_and_id
    "#{number}, z dn. #{date_exam}, #{place_exam} (#{id})"
  end

  def place_and_date
    "#{place_exam}, dn. #{date_exam}"
  end

  def esod_category_name
    Esodes::esod_matter_iks_name(esod_category)
  end


  def create_esod_matter
    esod_matter = Esod::Matter.create!(
      nrid: nil,
      znak: nil,
      znak_sprawy_grupujacej: nil,
      symbol_jrwa: Rails.application.secrets["esod_#{category.downcase}_jrwa"],
      tytul: "#{number}, #{place_exam}",
      termin_realizacji: date_exam,

      identyfikator_kategorii_sprawy: Rails.application.secrets["esod_exam_#{category.downcase}_identyfikator_kategorii_sprawy"],

      #identyfikator_kategorii_sprawy: esod_category,
      #identyfikator_kategorii_sprawy: Esodes::SESJA,

      adnotacja: "",
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
    esod_matter.tytul = "#{number}, #{place_exam}"
    esod_matter.termin_realizacji = date_exam
    if esod_matter.changed?
      esod_matter.netpar_user = user_id
      esod_matter.save! 
    end
  end

  def exam_has_examinations
    if self.examinations.any? 
      errors.add(:esod_category, " - Nie można zmieniać Rodzaju Sesji do której są przypisane Osoby Egzaminowane.")
    end
  end

  def exam_has_links
    analize_value = true
    if self.certificates.any? 
      errors[:base] << "Nie można usunąć Egzaminu do którego są przypisane Świadectwa."
      analize_value = false
    end
    if self.examinations.any? 
      errors[:base] << "Nie można usunąć Egzaminu do którego są przypisane Osoby Egzaminowane."
      analize_value = false
    end
    analize_value
  end
  
  # Scope for select2: "exam_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "M/2015 war"
  # * result   :
  #   * +scope+ -> collection 
  #
  scope :finder_exam, ->(q, category) { where( create_sql_string("#{q}", "#{category}") ) }

  # Method create SQL query string for finder select2: "exam_select"
  # * parameters   :
  #   * +category_scope+ -> category of exam %w(l m r). 
  #   * +query_str+ -> string for search. 
  #   Ex.: "M/2015 war"
  # * result   :
  #   * +sql_string+ -> string for SQL WHERE... 
  #
  def self.create_sql_string(query_str, category_scope)
    "(exams.category = '#{category_scope}') AND " + query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
  end

  # Method for glue parameters in create_sql_string
  # * parameters   :
  #   * +query_str+ -> word for search. 
  #   Ex.: "war"
  # * result   :
  #   * +sql_string+ -> SQL string query for one word 
  #
  def self.one_param_sql(query_str)
    escaped_query_str = sanitize("%#{query_str}%")
    "(" + %w(exams.number to_char(exams.date_exam,'YYYY-mm-dd') exams.place_exam).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end

  def generate_all_certificates(gen_user_id)
    for_generate_examinations =  Examination.joins(:division, :customer, :exam).where(exam_id: self.id, certificate: nil, examination_result: 'P').
                                  includes(:division, :customer, :exam, :certificate).references(:division, :customer, :exam, :certificate).order(:id).all

    for_generate_examinations.each do |examination| 

      examination.generate_certificate(gen_user_id)

    end

  end

end
