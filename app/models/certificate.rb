require 'esodes'

class Certificate < ActiveRecord::Base
  belongs_to :division
  belongs_to :exam, counter_cache: true
  belongs_to :customer
  belongs_to :user

  has_one :examination, dependent: :nullify

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, :source_type => "Certificate", dependent: :destroy
  has_many :esod_matters, class_name: "Esod::Matter", foreign_key: :certificate_id, dependent: :nullify

  # validates
  validates :number, presence: true,
                    length: { in: 1..30 },
                    uniqueness: { case_sensitive: false, scope: [:category] }
  validates :date_of_issue, presence: true
  validates :division, presence: true
  validates :customer, presence: true
  validates :exam, presence: true
  validates :user, presence: true
#  validates :esod_matter, uniqueness: true, allow_blank: true
  # ????? validates :esod_category, presence: true, inclusion: { in: Esodes::ALL_CATEGORIES_CERTIFICATES }
  validates :category, presence: true, inclusion: { in: %w(L M R) }
  validate  :valid_thru_if_not_blank_must_more_date_of_issue, if: "valid_thru.present? && date_of_issue.present?"

 
  def valid_thru_if_not_blank_must_more_date_of_issue
    if valid_thru.present? && valid_thru < date_of_issue
      errors.add(:valid_thru, "nie może być mniejsza od daty wydania")
    end
  end 

  # callbacks
  before_save { self.number = number.upcase }


  # scopes
	scope :only_category_l, -> { where(category: "L") }
	scope :only_category_m, -> { where(category: "M") }
	scope :only_category_r, -> { where(category: "R") }

  def fullname
    "#{number}, z dn. #{date_of_issue}"
  end

  def fullname_and_id
    "#{number}, z dn. #{date_of_issue} (#{id})"
  end

  def esod_category_name
    Esodes::esod_matter_iks_name(esod_category)
  end

  def flat_all_esod_matters
    self.esod_matters.order(:id).flat_map {|row| row.znak }.join(' <br>').html_safe
  end

 
  # Scope for select2: "certificate_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "a-123 war"
  # * result   :
  #   * +scope+ -> collection 
  #
  scope :finder_certificate, ->(q, category) { where( create_sql_string("#{q}", "#{category}") ) }

  # Method create SQL query string for finder select2: "certificate_select"
  # * parameters   :
  #   * +category_scope+ -> category of certificate %w(l m r). 
  #   * +query_str+ -> string for search. 
  #   Ex.: "a-1234"
  # * result   :
  #   * +sql_string+ -> string for SQL WHERE... 
  #
  def self.create_sql_string(query_str, category_scope)
    "(certificates.category = '#{category_scope}') AND " + query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
  end

  # Method for glue parameters in create_sql_string
  # * parameters   :
  #   * +query_str+ -> word for search. 
  #   Ex.: "a-123"
  # * result   :
  #   * +sql_string+ -> SQL string query for one word 
  #
  def self.one_param_sql(query_str)
    escaped_query_str = sanitize("%#{query_str}%")
    "(" + %w(certificates.number to_char(certificates.date_of_issue,'YYYY-mm-dd')).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end

  # Method for get string represent next certificate number for declared service and division
  # * parameters   :
  #   * +service+ -> word for declared service [l,m,r]. 
  #   Ex.: "r"
  #   * +division+ -> Division ID. 
  #   Ex.: "10"
  # * result   :
  #   * +number_string+ -> "A-12345" 
  #
  def self.next_certificate_number(service, division)
    division_scope = scope_numbering_groups(division) 
    next_nr = Certificate.get_next_number_certificate(service, division_scope).to_s
    next_nr_with_zeros = "00000#{next_nr}"      
    "#{division.number_prefix}#{next_nr_with_zeros.last(5)}"
  end

  # Method for get number represent next certificate number for declared service and division
  # * parameters   :
  #   * +service+ -> word for declared service [l,m,r]. 
  #   Ex.: "r"
  #   * +division+ -> Division ID. 
  #   Ex.: "10"
  # * result   :
  #   * +number+ -> 12345 
  #
  def self.get_next_number_certificate(service, division_scope)
    #q_res = Certificate.find_by_sql( ["SELECT max(abs(to_number(certificates.number,'999999999'))) AS number FROM certificates WHERE certificates.category = ? AND division_id IN (?)", service.upcase, division_scope] ).first.number    
    q_res = Certificate.where(category: service.upcase, division_id: division_scope).maximum("abs(to_number(certificates.number,'th999999')) ").to_i
    q_res += 1 
  end

  # Method for get aray of Division ID's represent same numbering group 
  # * parameters   :
  #   * +division+ -> Division ID. 
  #   Ex.: "10"
  # * result   :
  #   * +array+ -> [9, 10, 11, 12, 13, 14] 
  #
  def self.scope_numbering_groups(division)
    case division.id
    when 1..8   # common numbering for the entire range "L"
      [1, 2, 3, 4, 5, 6, 7, 8]
    when 9..14  # numbering for "M" divided into groups
      [9, 10, 11, 12, 13, 14]   # 9-G1E, 10-G2E, 11-GG, 12-GR, 13-GL, 14-GS  
    when 15           
      [15]                      # 15-MA
    when 16           
      [16]                      # 16-GC
    when 17           
      [17]                      # 17-IW
    when 18..21 # common numbering for the entire range "R"
      [18, 19, 20, 21]          # 18-A, 19-B, 20-C, 21-D
    else 
      []      
    end
  end

  # Method for get default valid_thru_date for declared division and date_off_ussue
  # * parameters   :
  #   * +start_date+ -> date same as date_off_issue. 
  #   Ex.: "2015-12-01T01:29:18"
  #   * +division+ -> Division ID. 
  #   Ex.: "10"
  # * result   :
  #   * +number+ -> "2020-12-01T01:29:18" 
  #
  def self.default_valid_thru_date(start_date, division)
    case division.id
    when 9..12  # certificate for category "M" divisions: 9-G1E, 10-G2E, 11-GG, 12-GR
      start_date + 5.years   
    else 
      nil       # other 
    end
  end

end
