class Division < ActiveRecord::Base

  DIVISION_M_G1E = 9  # G1E "świadectwo radioelektronika pierwszej klasy GMDSS"
  DIVISION_M_G2E = 10 # G2E "świadectwo radioelektronika pierwszej klasy GMDSS"
  DIVISION_M_GOC = 11 # GOC "świadectwo ogólne operatora GMDSS"
  DIVISION_M_ROC = 12 # ROC "świadectwo ograniczone operatora GMDSS"
  DIVISION_M_LRC = 13 # LRC "świadectwo operatora łączności dalekiego zasięgu LRC"
  DIVISION_M_SRC = 14 # SRC "świadectwo operatora łączności bliskiego zasięgu SRC"
  DIVISION_M_VHF = 15 # VHF "świadectwo operatora radiotelefonisty VHF"
  DIVISION_M_CSO = 16 # CSO "świadectwo operatora stacji nadbrzeżnej CSO"
  DIVISION_M_IWC = 17 # IWC "świadectwo operatora radiotelefonisty w służbie śródlądowej IWC"

  # DIVISION_M_FOR_SHOW = [ DIVISION_M_LRC, DIVISION_M_SRC, DIVISION_M_VHF, DIVISION_M_CSO, DIVISION_M_IWC ]  

  DIVISION_R_A = 18
  DIVISION_R_B = 19
  DIVISION_R_C = 20
  DIVISION_R_D = 21

#  DIVISION_R_FOR_SHOW = [ DIVISION_R_A, DIVISION_R_C ]  

  DIVISION_EXCLUDE_FOR_NEW = [ DIVISION_R_B, DIVISION_R_D ]  
  DIVISION_EXCLUDE_FOR_INTERNET = [ DIVISION_R_B, DIVISION_R_D, DIVISION_M_G1E, DIVISION_M_G2E, DIVISION_M_GOC, DIVISION_M_ROC, DIVISION_M_CSO ]  

  has_many :proposals  
  has_many :exam_fees  
  has_many :certificates  
  has_many :subjects, dependent: :destroy  

  has_many :exams_divisions, dependent: :destroy
  has_many :exams, through: :exams_divisions

  accepts_nested_attributes_for :subjects
  # accepts_nested_attributes_for :examiners,
  #                               reject_if: proc { |attributes| attributes['name'].blank? },
  #                               allow_destroy: true
  # validates
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:category] }
  validates :english_name, presence: true, allow_blank: true, uniqueness: { case_sensitive: false, scope: [:category] }
  validates :category, presence: true, inclusion: { in: %w(L M R) }
  validates :short_name, presence: true, length: { in: 1..10 }, uniqueness: { case_sensitive: false, scope: [:category] }
  validates :number_prefix, presence: true, length: { in: 1..10 }


  # scopes
  scope :only_category_scope, ->(cat)  { where(category: cat.upcase) }
  scope :by_name, -> { order(:name) }
  # scope :only_not_exclude, ->()  { where.not(id: DIVISION_EXCLUDE_FOR_NEW) }
  # scope :only_not_exclude_for_internet, ->()  { where.not(id: DIVISION_EXCLUDE_FOR_INTERNET) }
  scope :only_not_exclude, ->()  { where(for_new_certificate: true) }
  scope :only_not_exclude_for_internet, ->()  { where(proposal_via_internet: true) }


  # Scope for select2: "division_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "świad lr"
  # * result   :
  #   * +scope+ -> collection 
  #
  scope :finder_division, ->(q, category) { where( create_sql_string("#{q}", "#{category}") ) }

  # Method create SQL query string for finder select2: "division_select"
  # * parameters   :
  #   * +category_scope+ -> category of division %w(l m r). 
  #   * +query_str+ -> string for search. 
  #   Ex.: "świad lr"
  # * result   :
  #   * +sql_string+ -> string for SQL WHERE... 
  #
  def self.create_sql_string(query_str, category_scope)
    if query_str.blank?
      str_sql = "(divisions.category = '#{category_scope}')"
    else
      str_sql = "(divisions.category = '#{category_scope}') AND " + query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
    end

    return str_sql
  end

  # Method for glue parameters in create_sql_string
  # * parameters   :
  #   * +query_str+ -> word for search. 
  #   Ex.: "lr"
  # * result   :
  #   * +sql_string+ -> SQL string query for one word 
  #
  def self.one_param_sql(query_str)
    escaped_query_str = sanitize("%#{query_str}%")
    "(" + %w(divisions.name divisions.short_name to_char(divisions.min_years_old,'9999')).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end

end
