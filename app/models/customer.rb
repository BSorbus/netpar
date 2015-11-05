# Represents Client UKE
#  create_table "customers", force: :cascade do |t|
#    t.boolean  "human",                             default: true, null: false
#    t.string   "name",                  limit: 160, default: "",   null: false
#    t.string   "given_names",           limit: 50,  default: ""
#    t.string   "address_city",          limit: 50,  default: ""
#    t.string   "address_street",        limit: 50,  default: ""
#    t.string   "address_house",         limit: 10,  default: ""
#    t.string   "address_number",        limit: 10,  default: ""
#    t.string   "address_postal_code",   limit: 6,   default: ""
#    t.string   "address_post_office",   limit: 50,  default: ""
#    t.string   "address_pobox",         limit: 10,  default: ""
#    t.string   "c_address_city",        limit: 50,  default: ""
#    t.string   "c_address_street",      limit: 50,  default: ""
#    t.string   "c_address_house",       limit: 10,  default: ""
#    t.string   "c_address_number",      limit: 10,  default: ""
#    t.string   "c_address_postal_code", limit: 6,   default: ""
#    t.string   "c_address_post_office", limit: 50,  default: ""
#    t.string   "c_address_pobox",       limit: 10,  default: ""
#    t.string   "nip",                   limit: 13,  default: ""
#    t.string   "regon",                 limit: 9,   default: ""
#    t.string   "pesel",                 limit: 11,  default: ""
#    t.date     "birth_date"
#    t.string   "birth_place",           limit: 50,  default: ""
#    t.string   "fathers_name",          limit: 50,  default: ""
#    t.string   "mothers_name",          limit: 50,  default: ""
#    t.string   "family_name",           limit: 50,  default: ""
#    t.integer  "citizenship_id",                    default: 2
#    t.string   "phone",                 limit: 50,  default: ""
#    t.string   "fax",                   limit: 50,  default: ""
#    t.string   "email",                 limit: 50,  default: ""
#    t.text     "note",                              default: ""
#    t.integer  "user_id"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
#  add_index "customers", ["address_city"], name: "index_customers_on_address_city", using: :btree
#  add_index "customers", ["birth_date"], name: "index_customers_on_birth_date", using: :btree
#  add_index "customers", ["citizenship_id"], name: "index_customers_on_citizenship_id", using: :btree
#  add_index "customers", ["given_names"], name: "index_customers_on_given_names", using: :btree
#  add_index "customers", ["name"], name: "index_customers_on_name", using: :btree
#  add_index "customers", ["nip"], name: "index_customers_on_nip", using: :btree
#  add_index "customers", ["pesel"], name: "index_customers_on_pesel", using: :btree
#  add_index "customers", ["regon"], name: "index_customers_on_regon", using: :btree
#  add_index "customers", ["user_id"], name: "index_customers_on_user_id", using: :btree
#
class Customer < ActiveRecord::Base

  require 'pesel'

  belongs_to :citizenship
  belongs_to :user

  has_many :documents, as: :documentable
  has_many :works, as: :trackable

  has_many :individuals
  has_many :individualed_documentable, through: :individuals, source: :documents

  has_many :certificates
  has_many :certificated_documentable, through: :certificates, source: :documents

  has_many :examinations
  has_many :examinationed_documentable, through: :examinations, source: :documents

  has_many :exams, through: :certificates
  has_many :examed_documentable, through: :exams, source: :documents



  # validates
  validates :name, presence: true,
                    length: { in: 1..160 }
  validates :given_names, presence: true,
                    length: { in: 1..50 }, if: :is_human? 
  validates :address_city, presence: true,
                    length: { in: 1..50 }
  validates :pesel, length: { is: 11 }, numericality: true, 
                    uniqueness: { case_sensitive: false }, allow_blank: true
  validates :birth_date, presence: true, if: :is_human?
  validate :check_pesel_and_birth_date, unless: "pesel.blank?"
  validate :unique_name_given_names_birth_date_birth_place_fathers_name, if: :is_human?

  validates :citizenship, presence: true
  validates :user, presence: true

  before_destroy :customer_has_links, prepend: true

  def check_pesel_and_birth_date
    p = Pesel.new(pesel)
    errors.add(:pesel, ' - Błędny numer') unless p.valid?
    if p.valid? 
      errors.add(:birth_date, " niezgodna z datą zapisaną w numerze PESEL (#{p.birth_date})") unless p.birth_date == birth_date
    end
  end

  def unique_name_given_names_birth_date_birth_place_fathers_name
    if Customer.where(name: name, given_names: given_names, birth_date: birth_date, birth_place: birth_place, fathers_name: fathers_name).where.not(id: id).any? 
      errors.add(:base, "Błąd! Klient: \"#{name} #{given_names} ur.#{birth_place} #{birth_date}, ojciec: #{fathers_name}\" jest już zarejestrowany!")
    end
  end

  def customer_has_links
    analize_value = true
    if self.certificates.any? 
      errors[:base] << "Nie można usunąć konta Klienta do którego są przypisane Świadectwa."
      analize_value = false
    end
    if self.examinations.any? 
      errors[:base] << "Nie można usunąć konta Klienta do którego są przypisane Egzaminy."
      analize_value = false
    end
    #if Family.where(company_id: id).any? 
    #  errors[:base] << "Nie można usunąć Firmy, która ma przypisane Polisy Rodzina"
    #  analize_value = false
    #end
    analize_value
  end

  def is_human?
    human == true
  end

  def fullname
    "#{name} #{given_names}"
  end

  def fullname_and_id
    "#{name} #{given_names} (#{id})"
  end

  def fullname_and_address
    res = "#{name} #{given_names}, #{address_city}"
    res +=  ", ul.#{address_street}" if address_street.present?
    res +=  " #{address_house}" if address_house.present?
    res +=  "/#{address_number}" if address_number.present?
    res
  end

  def fullname_and_address_for_envelope
    if c_address_city.present?
      res =  "#{given_names} #{name} \n"
      res += "ul. #{c_address_street}" if c_address_street.present?
      res += " #{c_address_house}" if c_address_house.present?
      res += "/#{c_address_number}" if c_address_number.present?
      res += "\n #{c_address_postal_code} #{c_address_city}"
      res += "\n skrytka: #{c_address_pobox}" if c_address_pobox.present?
      res += "\n poczta: #{c_address_post_office}" if c_address_post_office.present? && c_address_city != c_address_post_office
    else
      res =  "#{given_names} #{name} \n"
      res += "ul. #{address_street}" if address_street.present?
      res += " #{address_house}" if address_house.present?
      res += "/#{address_number}" if address_number.present?
      res += "\n #{address_postal_code} #{address_city}"
      res += "\n skrytka: #{address_pobox}" if address_pobox.present?
      res += "\n poczta: #{address_post_office}" if address_post_office.present? && address_city != address_post_office
    end
    res
  end

  def fullname_and_address_and_pesel_nip
    res = fullname_and_address
    res +=  ", #{pesel}" if pesel.present?
    res +=  ", #{nip}" if nip.present?
    res
  end

  def fullname_and_address_and_pesel_nip_and_birth_date
    res = fullname_and_address_and_pesel_nip
    res +=  ", ur.#{birth_date}" if birth_date.present?
    res
  end

  def birth_date_and_place
    str = birth_date.present? ? birth_date.strftime("%d.%m.%Y") : "" 
    "#{str} #{birth_place}"
  end


  # Scope for select2: "customer_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "kowal warsz"
  # * result   :
  #   * +scope+ -> collection 
  #
  scope :finder_customer, ->(q) { where( create_sql_string("#{q}") ) }

  # Method create SQL query string for finder select2: "customer_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "kowal warsz"
  # * result   :
  #   * +sql_string+ -> string for SQL WHERE... 
  #   Ex.: "((customers.name ilike '%kowal%' OR customers.given_names ilike '%kowal%' OR customers.address_city ilike '%kowal%' OR customers.pesel ilike '%kowal%' OR to_char(customers.birth_date,'YYYY-mm-dd') ilike '%kowal%') AND (customers.name ilike '%warsz%' OR customers.given_names ilike '%warsz%' OR customers.address_city ilike '%warsz%' OR customers.pesel ilike '%warsz%' OR to_char(customers.birth_date,'YYYY-mm-dd') ilike '%warsz%'))"
  #
  def self.create_sql_string(query_str)
    query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
  end

  # Method for glue parameters in create_sql_string
  # * parameters   :
  #   * +query_str+ -> word for search. 
  #   Ex.: "kowal"
  # * result   :
  #   * +sql_string+ -> SQL string query for one word 
  #   Ex.: "(customers.name ilike '%kowal%' OR customers.given_names ilike '%kowal%' OR customers.address_city ilike '%kowal%' OR customers.pesel ilike '%kowal%' OR to_char(customers.birth_date,'YYYY-mm-dd') ilike '%kowal%')"
  #
  def self.one_param_sql(query_str)
    escaped_query_str = sanitize("%#{query_str}%")
    "(" + %w(customers.name customers.given_names customers.address_city customers.pesel to_char(customers.birth_date,'YYYY-mm-dd')).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end

  # method for joining Customer records
  # * paramaters   :
  #   * +source_customer+ -> instance object class Customer for merge with self
  #
  def join_with_another(source_customer)
    unless self.id == source_customer.id
      source_customer.certificates.update_all(customer_id: self.id)
      source_customer.examinations.update_all(customer_id: self.id)
      source_customer.individuals.update_all(customer_id: self.id)
      source_customer.destroy!
    end
  end

end
