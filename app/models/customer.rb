# Represents Client UKE
#  create_table "customers", force: :cascade do |t|
#    t.boolean  "human",                             default: true, null: false
#    t.string   "name",                  limit: 160, default: "",   null: false
#    t.string   "given_names",           limit: 50,  default: ""
#    t.string   "address_city",          limit: 50,  default: ""
#    t.string   "address_street",        limit: 50,  default: ""
#    t.string   "address_house",         limit: 10,  default: ""
#    t.string   "address_number",        limit: 10,  default: ""
#    t.string   "address_postal_code",   limit: 10,  default: ""
#    t.string   "address_post_office",   limit: 50,  default: ""
#    t.string   "address_pobox",         limit: 10,  default: ""
#    t.string   "c_address_city",        limit: 50,  default: ""
#    t.string   "c_address_street",      limit: 50,  default: ""
#    t.string   "c_address_house",       limit: 10,  default: ""
#    t.string   "c_address_number",      limit: 10,  default: ""
#    t.string   "c_address_postal_code", limit: 10,  default: ""
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
#    t.boolean  "address_in_poland",                       default: true, null: false
#    t.boolean  "c_address_in_poland",                     default: true, null: false
#    t.integer  "address_teryt_pna_code_id"
#    t.integer  "c_address_teryt_pna_code_id"
#    t.integer  "esod_contractor_id"
#    t.integer  "esod_address_id"
#  end
#  add_index "customers", ["address_city"], name: "index_customers_on_address_city", using: :btree
#  add_index "customers", ["address_street"], name: "index_customers_on_address_street", using: :btree
#  add_index "customers", ["address_teryt_pna_code_id"], name: "index_customers_on_address_teryt_pna_code_id", using: :btree
#  add_index "customers", ["birth_date"], name: "index_customers_on_birth_date", using: :btree
#  add_index "customers", ["c_address_teryt_pna_code_id"], name: "index_customers_on_c_address_teryt_pna_code_id", using: :btree
#  add_index "customers", ["citizenship_id"], name: "index_customers_on_citizenship_id", using: :btree
#  add_index "customers", ["esod_address_id"], name: "index_customers_on_esod_address_id", using: :btree
#  add_index "customers", ["esod_contractor_id"], name: "index_customers_on_esod_contractor_id", using: :btree
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
  belongs_to :address_teryt_pna_code, class_name: "Teryt::PnaCode", foreign_key: :address_teryt_pna_code_id
  belongs_to :c_address_teryt_pna_code, class_name: "Teryt::PnaCode", foreign_key: :c_address_teryt_pna_code_id
  belongs_to :esod_contractor, class_name: "Esod::Contractor", foreign_key: :esod_contractor_id#, dependent: :delete
  belongs_to :esod_address, class_name: "Esod::Address", foreign_key: :esod_address_id

  has_many :documents, as: :documentable
  has_many :works, as: :trackable

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
  validates :address_postal_code, presence: true,
                    length: { in: 6..10 }
  validates :c_address_postal_code,
                    length: { in: 6..10 }, if: "c_address_postal_code.present?"
  validates :pesel, length: { is: 11 }, numericality: true, 
                    uniqueness: { case_sensitive: false }, allow_blank: true
  validates :birth_date, presence: true, if: :is_human?
  validate :check_pesel_and_birth_date, unless: "pesel.blank?"
  validate :unique_name_given_names_birth_date_birth_place_fathers_name, if: :is_human?
  validate :check_address_on_teryt_pna, unless: :is_address_in_poland?
  validate :check_c_address_on_teryt_pna, unless: :is_c_address_in_poland?, if: "c_address_postal_code.present? || c_address_city.present? || c_address_street.present? || c_address_post_office.present?"

  validates :citizenship, presence: true
  validates :user, presence: true

  # callbacks
  before_save :create_esod_contractor, if: "esod_contractor_id.blank?"
  before_save :update_esod_contractor, unless: "esod_contractor_id.blank?"
  before_save :create_esod_address, if: "esod_address_id.blank?"
  before_save :update_esod_address, unless: "esod_address_id.blank?"

  before_destroy :customer_has_links, prepend: true



  def is_human?
    human == true
  end

  def is_address_in_poland?
    address_in_poland == true
  end

  def is_c_address_in_poland?
    c_address_in_poland == true
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
      res += c_address_street.present? ? "ul. #{c_address_street}" : "#{c_address_city}" 
      res += " #{c_address_house}" if c_address_house.present?
      res += "/#{c_address_number}" if c_address_number.present?
      res += "\n #{c_address_postal_code} #{c_address_post_office}"
      res += "\n skrytka: #{c_address_pobox}" if c_address_pobox.present?
    else
      res =  "#{given_names} #{name} \n"
      res += address_street.present? ? "ul. #{address_street}" : "#{address_city}" 
      res += " #{address_house}" if address_house.present?
      res += "/#{address_number}" if address_number.present?
      res += "\n #{address_postal_code} #{address_post_office}"
      res += "\n skrytka: #{address_pobox}" if address_pobox.present?
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


  def create_esod_contractor
    esod_contractor = Esod::Contractor.create!(
      nrid: nil,
      imie: is_human? ? "#{given_names}".split(%r{,\s*})[0] : "",
      nazwisko: is_human? ? name : "",
      nazwa: is_human? ? "" : name,
      drugie_imie: is_human? ? "#{given_names}".split(%r{,\s*})[1] : "",
      tytul: nil,
      nip: "#{nip}",
      pesel: "#{pesel}",
      rodzaj: is_human? ? 1 : 2, 
      initialized_from_esod: false,
      netpar_user: user_id
    )
    self.esod_contractor = esod_contractor 
  end

  def update_esod_contractor
    esod_contractor = Esod::Contractor.find_by(id: esod_contractor_id)
    esod_contractor.imie = is_human? ? "#{given_names}".split(%r{,\s*})[0] : "",
    esod_contractor.nazwisko = is_human? ? name : "",
    esod_contractor.nazwa = is_human? ? "" : name,
    esod_contractor.drugie_imie = is_human? ? "#{given_names}".split(%r{,\s*})[1] : "",
    esod_contractor.nip = "#{nip}",
    esod_contractor.pesel = "#{pesel}",
    esod_contractor.rodzaj = is_human? ? 1 : 2, 
    if esod_contractor.changed?
      esod_contractor.netpar_user = user_id
      esod_contractor.save! 
    end
  end


  def create_esod_address
    esod_address = Esod::Address.create!(
      nrid: nil,
      miasto: c_address_city.present? ? "#{c_address_city}" : "#{address_city}",
      kod_pocztowy: c_address_postal_code.present? ? "#{c_address_postal_code}" : "#{address_postal_code}",
      ulica: c_address_street.present? ? "#{c_address_street}" : "#{address_street}",
      numer_lokalu: c_address_number.present? ? "#{c_address_number}" : "#{address_number}",
      numer_budynku: c_address_house.present? ? "#{c_address_house}" : "#{address_house}",
      skrytka_epuap: nil,
      panstwo: "#{citizenship.name}",
      email: email, 
      typ: "fizyczny", 
      initialized_from_esod: false,
      netpar_user: user_id
    )
    self.esod_address = esod_address 
  end

  def update_esod_address
    esod_address = Esod::Address.find_by(id: esod_address_id)
    esod_address.miasto = c_address_city.present? ? "#{c_address_city}" : "#{address_city}",
    esod_address.kod_pocztowy = c_address_postal_code.present? ? "#{c_address_postal_code}" : "#{address_postal_code}",
    esod_address.ulica = c_address_street.present? ? "#{c_address_street}" : "#{address_street}",
    esod_address.numer_lokalu = c_address_number.present? ? "#{c_address_number}" : "#{address_number}",
    esod_address.numer_budynku = c_address_house.present? ? "#{c_address_house}" : "#{address_house}",
    esod_address.panstwo = "#{citizenship.name}",
    esod_address.email = email, 
    if esod_address.changed?
      esod_address.netpar_user = user_id
      esod_address.save! 
    end
  end


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

  def check_address_on_teryt_pna
    teryt_pna_code = Teryt::PnaCode.find_by(pna: address_postal_code)
    teryt_pna_code = Teryt::PnaCode.find_by(sym_nazwa: address_city, uli_nazwa: address_street) unless teryt_pna_code.present?
    teryt_pna_code = Teryt::PnaCode.find_by(sympod_nazwa: address_city, uli_nazwa: address_street) unless teryt_pna_code.present?
    teryt_pna_code = Teryt::PnaCode.find_by(sym_nazwa: address_post_office, uli_nazwa: address_street) unless teryt_pna_code.present?
    teryt_pna_code = Teryt::PnaCode.find_by(sympod_nazwa: address_post_office, uli_nazwa: address_street) unless teryt_pna_code.present?
    errors.add(:base, "Błąd! Nie można wyłączać weyfikacji TERYT+PNA dla adresów występujących w rejestrze") if teryt_pna_code.present?
    errors.add(:address_in_poland, " -  zaznacz weryfikowanie") if teryt_pna_code.present?
    analize_value = false
  end

  def check_c_address_on_teryt_pna
    teryt_pna_code = Teryt::PnaCode.find_by(pna: c_address_postal_code)
    teryt_pna_code = Teryt::PnaCode.find_by(sym_nazwa: c_address_city, uli_nazwa: c_address_street) unless teryt_pna_code.present?
    teryt_pna_code = Teryt::PnaCode.find_by(sympod_nazwa: c_address_city, uli_nazwa: c_address_street) unless teryt_pna_code.present?
    teryt_pna_code = Teryt::PnaCode.find_by(sym_nazwa: c_address_post_office, uli_nazwa: c_address_street) unless teryt_pna_code.present?
    teryt_pna_code = Teryt::PnaCode.find_by(sympod_nazwa: c_address_post_office, uli_nazwa: c_address_street) unless teryt_pna_code.present?
    errors.add(:base, "Błąd! Nie można wyłączać weyfikacji TERYT+PNA dla adresów występujących w rejestrze") if teryt_pna_code.present?
    errors.add(:c_address_in_poland, " -  zaznacz weryfikowanie") if teryt_pna_code.present?
    analize_value = false
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
    analize_value
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
      source_customer.documents.update_all(documentable_id: self.id)
      source_customer.works.update_all(trackable_id: self.id)
      source_customer.destroy!
    end
  end

end
