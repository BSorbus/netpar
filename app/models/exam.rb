require 'esodes'

class Exam < ActiveRecord::Base
  belongs_to :user
 
  has_many :certificates, dependent: :destroy
  has_many :examinations, dependent: :destroy
  has_many :proposals, dependent: :destroy
  has_many :examiners, inverse_of: :exam, dependent: :destroy  

  accepts_nested_attributes_for :examiners,
                                reject_if: proc { |attributes| attributes['name'].blank? },
                                allow_destroy: true
  validates_associated :examiners

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, dependent: :destroy
  has_many :certificate_customers, through: :certificates, source: :customer
  has_many :examination_customers, through: :examinations, source: :customer
  has_many :esod_matters, class_name: "Esod::Matter", foreign_key: :exam_id, dependent: :nullify

  has_many :exams_divisions, dependent: :destroy
  has_many :divisions, through: :exams_divisions

  accepts_nested_attributes_for :examiners, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :exams_divisions, reject_if: :all_blank, allow_destroy: true

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

  validates :province_id, presence: true
  validates :max_examinations, numericality: true, allow_blank: true

#  validates :esod_matter, uniqueness: { case_sensitive: false }, allow_blank: true
  validate :exam_has_examinations, on: :update, if: "esod_category != esod_category_was"


  # scopes
	scope :only_category_l, -> { where(category: "L") }
	scope :only_category_m, -> { where(category: "M") }
	scope :only_category_r, -> { where(category: "R") }

  # callbacks
  before_save { self.number = number.upcase }
  before_save :save_province_name, if: :province_id_changed? 
  before_destroy :exam_has_links, prepend: true


  def save_province_name
    province = PitTerytProvince.new(id: province_id)
    province.run_request
    self.province_name = province.name
  end


  def fullname
    "#{number}, z dn. #{date_exam}, #{place_exam} [#{province_name}]"
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

  def flat_all_esod_matters
    self.esod_matters.order(:id).flat_map {|row| row.znak }.join(' <br>').html_safe
  end

  def refresh_proposals_important_count
    update_columns(proposals_important_count: proposals.where(proposal_status_id: ProposalStatus::PROPOSAL_IMPORTANT_STATUSES).size)
  end

  def exam_has_examinations
    analize_value = true
    if self.examinations.any? 
      errors.add(:esod_category, " - Nie można zmieniać Rodzaju Sesji do której są przypisane Osoby Egzaminowane.")
      analize_value = false
    end
    if self.proposals.any? 
      errors.add(:esod_category, " - Nie można zmieniać Rodzaju Sesji do której złożone Elektronicznie Zgłoszenia.")
      analize_value = false
    end
    analize_value
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
    if self.proposals.any? 
      errors[:base] << "Nie można usunąć Egzaminu do którego są złożone Elektroniczne Zgłoszenia."
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
    if query_str.blank?
      str_sql = "(exams.category = '#{category_scope}')"
    else
      str_sql = "(exams.category = '#{category_scope}') AND " + query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
    end

    return str_sql
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
    "(" + %w(exams.number to_char(exams.date_exam,'YYYY-mm-dd') exams.place_exam exams.province_name).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end

  def generate_all_certificates(gen_user_id)
    for_generate_examinations =  Examination.joins(:division, :customer, :exam).where(exam_id: self.id, certificate: nil, examination_result: 'P').
                                  includes(:division, :customer, :exam, :certificate).references(:division, :customer, :exam, :certificate).order(:id).all
    for_generate_examinations.each do |examination|
      examination.generate_certificate(gen_user_id)
    end

  end

end
