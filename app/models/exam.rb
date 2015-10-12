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
#    t.integer  "code"
#  end
#  add_index "exams", ["category"], name: "index_exams_on_category", using: :btree
#  add_index "exams", ["date_exam"], name: "index_exams_on_date_exam", using: :btree
#  add_index "exams", ["number", "category"], name: "index_exams_on_number_and_category", unique: true, using: :btree
#  add_index "exams", ["user_id"], name: "index_exams_on_user_id", using: :btree
#
class Exam < ActiveRecord::Base
  belongs_to :user
  has_many :certificates, dependent: :destroy
  has_many :examinations, dependent: :destroy

  has_many :examiners, dependent: :destroy  

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



#  # validates
#  validates :number, presence: true,
#                    length: { in: 1..30 },
#                    :uniqueness => { :case_sensitive => false, :scope => [:category] }

#  validates :date_exam, presence: true
#  validates :place_exam, presence: true,
#                    length: { in: 1..50 }
#  validates :category, inclusion: { in: %w(L M R) }
#  validates :user, presence: true


  # scopes
	scope :only_category_l, -> { where(category: "L") }
	scope :only_category_m, -> { where(category: "M") }
	scope :only_category_r, -> { where(category: "R") }

  before_save { self.number = number.upcase }

  def fullname
    "#{number}, z dn. #{date_exam}, #{place_exam}"
  end

  def fullname_and_id
    "#{number}, z dn. #{date_exam}, #{place_exam} (#{id})"
  end

  def place_and_date
    "#{place_exam}, dn. #{date_exam}"
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
                                  includes(:division, :customer, :exam, :certificate).references(:division, :customer, :exam, :certificate).order("customers.name, customers.given_names").all

    for_generate_examinations.each do |examination|

      examination.generate_certificate(gen_user_id)

    end

  end

end
