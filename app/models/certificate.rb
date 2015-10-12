# Represents Certificate for Customer
#  create_table "certificates", force: :cascade do |t|
#    t.string   "number",             limit: 30, default: "",  null: false
#    t.date     "date_of_issue"
#    t.date     "valid_thru"
#    t.string   "certificate_status", limit: 1,  default: "N", null: false
#    t.integer  "division_id"
#    t.integer  "exam_id"
#    t.integer  "customer_id"
#    t.text     "note",                          default: ""
#    t.string   "category"
#    t.integer  "user_id"
#    t.datetime "created_at",                                  null: false
#    t.datetime "updated_at",                                  null: false
#  end
#  add_index "certificates", ["category"], name: "index_certificates_on_category", using: :btree
#  add_index "certificates", ["customer_id"], name: "index_certificates_on_customer_id", using: :btree
#  add_index "certificates", ["date_of_issue"], name: "index_certificates_on_date_of_issue", using: :btree
#  add_index "certificates", ["division_id"], name: "index_certificates_on_division_id", using: :btree
#  add_index "certificates", ["exam_id"], name: "index_certificates_on_exam_id", using: :btree
#  add_index "certificates", ["number", "category"], name: "index_certificates_on_number_and_category", unique: true, using: :btree
#  add_index "certificates", ["number"], name: "index_certificates_on_number", using: :btree
#  add_index "certificates", ["user_id"], name: "index_certificates_on_user_id", using: :btree
#
class Certificate < ActiveRecord::Base
  belongs_to :division
  belongs_to :exam
  belongs_to :customer
  belongs_to :user

  has_one :examination, dependent: :nullify

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, :source_type => "Certificate", dependent: :destroy



#  # validates
#  validates :number, presence: true,
#                    length: { in: 1..30 },
#                    uniqueness: { :case_sensitive => false, :scope => [:category] }
#  validates :date_of_issue, presence: true
#  validates :division, presence: true
#  validates :customer, presence: true
#  validates :exam, presence: true
#  validates :user, presence: true
#  validates :category, inclusion: { in: %w(L M R) }
#  validate  :valid_thru_if_not_blank_must_more_date_of_issue, unless: "valid_thru.blank?"

 
  def valid_thru_if_not_blank_must_more_date_of_issue
    if valid_thru.present? && valid_thru < date_of_issue
      errors.add(:valid_thru, "nie może być mniejsza od daty wydania")
    end
  end 

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

  def certificate_status_name
    case certificate_status
    when 'D'
      'Duplicat'   
    when 'N'
      'Nowe'
    when 'O'
      'Odnowione' 
    when 'S'
      'Skreślone (nieważne)' 
    when 'W'
      'Wymienione (odnowione)' 
    end
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

  def self.next_certificate_number(service, division)
    division_scope = scope_numbering_groups(division) 
    next_nr = Certificate.get_next_number_certificate(service, division_scope).to_s
    next_nr_with_zeros = "00000#{next_nr}"      
    "#{division.number_prefix}#{next_nr_with_zeros.last(5)}"
  end

  def self.get_next_number_certificate(service, division_scope)
    #q_res = Certificate.find_by_sql( ["SELECT max(abs(to_number(certificates.number,'999999999'))) AS number FROM certificates WHERE certificates.category = ? AND division_id IN (?)", service.upcase, division_scope] ).first.number    
    q_res = Certificate.where(category: service.upcase, division_id: division_scope).maximum("abs(to_number(certificates.number,'th999999')) ").to_i
    q_res += 1 
  end

  def self.scope_numbering_groups(division)
    case division.id
    when 1..8             # wspólna numeracja dla całego zakresu  "L"
      [1, 2, 3, 4, 5, 6, 7, 8]
    when 9..14            # numeracja dla "M" jest podzielona na grupy
      [9, 10, 11, 12, 13, 14]  # 9-G1E, 10-G2E, 11-GG, 12-GR, 13-GL, 14-GS  
    when 15           
      [15]                # 15-MA
    when 16           
      [16]                # 16-GC
    when 17           
      [17]                # 17-IW
    when 18..21           # wspólna numeracja dla całego zakresu "R"
      [18, 19, 20, 21]       # 18-A, 19-B, 20-C, 21-D
    else 
      []      
    end
  end

end
