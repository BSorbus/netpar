require 'esodes'

class Customer < ActiveRecord::Base
  require 'pesel'

  belongs_to :citizenship
  belongs_to :user
  belongs_to :address_teryt_pna_code, class_name: "Teryt::PnaCode", foreign_key: :address_teryt_pna_code_id
  belongs_to :c_address_teryt_pna_code, class_name: "Teryt::PnaCode", foreign_key: :c_address_teryt_pna_code_id

  has_one :esod_contractor, class_name: "Esod::Contractor", dependent: :nullify
  has_one :esod_address, class_name: "Esod::Address", dependent: :nullify

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
  #before_save :create_esod_contractor, if: "esod_contractor_id.blank?"
  #before_save :update_esod_contractor, unless: "esod_contractor_id.blank?"
  #before_save :create_esod_address, if: "esod_address_id.blank?"
  #before_save :update_esod_address, unless: "esod_address_id.blank?"

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
  # * parameters   :
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


  def insert_data_to_esod_and_update_self(options = {})
    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Esodes::ESOD_API_SERVER}/wsdl/slowniki/ws/slowniki.wsdl",
      endpoint: "#{Esodes::ESOD_API_SERVER}/uslugi.php/slowniki/handle",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                   "xmlns:slow" => "http://www.dokus.pl/slowniki/ws/slowniki", 
                   "xmlns:slow1" => "http://www.dokus.pl/slowniki/mt/slowniki", 
                   "xmlns:wsp" => "http://www.dokus.pl/wspolne",
                   "xmlns:ns1" => "http://www.dokus.pl/wspolne", 
                   "xmlns:ns2" => "http://www.dokus.pl/slowniki/mt/slowniki", 
                   "xmlns:ns3" => "http://www.dokus.pl/slowniki/ws/slowniki"
                   },
      namespace_identifier: :slow, #"xmlns:slow" => "http://www.dokus.pl/slowniki/ws/slowniki/utworzKontrahenta", 
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
      soap_version: 2,
      # Tutaj musi być podawane Login i Pobrany Token, a nie hash_password
      #wsse_auth: [my_login, "7584b77307868d6fde1dd9dbad28f2403d57d8d19826d13932aca4fad9fa88a41df1cddb28e0aad11b607e0b756da42cb02f2ff2a46809c0b9df6647f3d6a8fc"]
      wsse_auth: [Esodes::EsodTokenData.netpar_user.email, Esodes::EsodTokenData.token_string],
      soap_header: { "wsp:metaParametry" => 
                      { "wsp:identyfikatorStanowiska" => Esodes::EsodTokenData.token_stanowiska.first[:nrid] } 
                    }
    )

    message_body = { 
      "slow1:daneTworzeniaOsoby" => {
        "slow1:imie" => given_names,
        "slow1:nazwisko" => name,
        "slow1:pesel" => pesel,
        "slow1:rodzaj" => {
          "slow1:nrid" => 1
          }
      },
      "slow1:daneTworzeniaAdresu" => { 
        "slow1:miasto" => address_city,
        "slow1:kodPocztowy" => address_postal_code,
        "slow1:ulica" => address_street,
        "slow1:numerLokalu" => address_number,
        "slow1:numerBudynku" => address_house,
        "slow1:panstwo" => self.citizenship.short,
        "slow1:typ" => "fizyczny"
      },
      "slow1:ignorujTeryt" => true
    }

    response = client.call(:utworz_kontrahenta,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='osoba']").each do |row|      
        unless self.esod_contractor.present? 
          contractor = self.build_esod_contractor(
            data_utworzenia: row.xpath("./*[local-name()='dataUtworzenia']").text,
            identyfikator_osoby_tworzacej: row.xpath("./*[local-name()='identyfikatorOsobyTworzacej']").text,
            data_modyfikacji: row.xpath("./*[local-name()='dataModyfikacji']").text,
            identyfikator_osoby_modyfikujacej: row.xpath("./*[local-name()='identyfikatorOsobyModyfikujacej']").text,
            nrid: row.xpath("./*[local-name()='nrid']").text,
            imie: row.xpath("./*[local-name()='imie']").text,
            nazwisko: row.xpath("./*[local-name()='nazwisko']").text,
            pesel: row.xpath('//ns2:pesel').text
          )
          contractor.save
        end
      end 

      response.xpath("//*[local-name()='adres']").each do |row|      
        unless self.esod_address.present? 
          address = self.build_esod_address(
            data_utworzenia: row.xpath("./*[local-name()='dataUtworzenia']").text,
            identyfikator_osoby_tworzacej: row.xpath("./*[local-name()='identyfikatorOsobyTworzacej']").text,
            data_modyfikacji: row.xpath("./*[local-name()='dataModyfikacji']").text,
            identyfikator_osoby_modyfikujacej: row.xpath("./*[local-name()='identyfikatorOsobyModyfikujacej']").text,
            nrid: row.xpath("./*[local-name()='nrid']").text,
            miasto: row.xpath("./*[local-name()='miasto']").text,
            kod_pocztowy: row.xpath("./*[local-name()='kodPocztowy']").text,
            ulica: row.xpath("./*[local-name()='ulica']").text,
            numer_lokalu: row.xpath("./*[local-name()='numerLokalu']").text,
            numer_budynku: row.xpath("./*[local-name()='numerBudynku']").text,
            panstwo: row.xpath("./*[local-name()='panstwo']").text,
            typ: row.xpath("./*[local-name()='typ']").text
          )
          address.save
        end
      end

    end

    rescue Savon::HTTPError => error
      puts '==================================================================='
      puts '      ----- Savon::HTTPError => error error.http.code -----'
      puts "error.http.code: #{error.http.code}"
      puts "      faultcode: #{error.to_hash[:fault][:faultcode]}"
      puts "    faultstring: #{error.to_hash[:fault][:faultstring]}"
      puts "         detail: #{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      #raise

    rescue Savon::SOAPFault => error
      puts '==================================================================='
      puts '      ----- Savon::SOAPFault => error error.http.code -----'
      puts "error.http.code: #{error.http.code}"
      puts "      faultcode: #{error.to_hash[:fault][:faultcode]}"
      puts "    faultstring: #{error.to_hash[:fault][:faultstring]}"
      puts "         detail: #{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      #raise CustomError, fault_code
      #raise
  end


end
