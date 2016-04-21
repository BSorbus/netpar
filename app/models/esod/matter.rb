include  ActionView::Helpers::TextHelper
require 'esodes'

class Esod::Matter < ActiveRecord::Base
  has_one :exam, foreign_key: :esod_matter_id, dependent: :nullify
  has_one :examination, foreign_key: :esod_matter_id, dependent: :nullify
#  belongs_to :certificate

  has_many :esod_matter_notes, class_name: 'Esod::MatterNote', primary_key: 'id', foreign_key: 'esod_matter_id'

  has_many :esod_incoming_letters_matters, class_name: 'Esod::IncomingLettersMatter', foreign_key: :esod_matter_id 
  has_many :esod_incoming_letters, through: :esod_incoming_letters_matters, primary_key: :esod_incoming_letter_id

  has_many :esod_outgoing_letters_matters, class_name: 'Esod::OutgoingLettersMatter', foreign_key: :esod_matter_id 
  has_many :esod_outgoing_letters, through: :esod_outgoing_letters_matters, primary_key: :esod_outgoing_letter_id

  has_many :esod_internal_letters_matters, class_name: 'Esod::InternalLettersMatter', foreign_key: :esod_matter_id 
  has_many :esod_internal_letters, through: :esod_internal_letters_matters, primary_key: :esod_internal_letter_id


#  has_and_belongs_to_many :esod_incoming_letters, class_name: "Esod::IncomingLetter", foreign_key: :esod_matter_id,
#    association_foreign_key: :esod_incoming_letter_id, join_table: :esod_incoming_letters_matters


  def fullname
    "#{znak}, #{truncate(tytul, length: 85)}, #{termin_realizacji}, [#{iks_name}] #{truncate(adnotacja, length: 20)}"
  end

  def iks_name
    Esodes::esod_matter_iks_name(identyfikator_kategorii_sprawy)
  end

  def exam_number
    "#{tytul}".split(%r{,\s*})[0]
  end

  def exam_place
    "#{tytul}".split(%r{,\s*})[1]
  end



  def insert_data_to_esod_and_update_self
    esod_user = User.find_by(netpar_user)
    esod_user_email = esod_user.email
    esod_user_pass =  esod_user.esod_encryped_password
    responseToken = Esod::Token.new(esod_user_email, esod_user_pass)
    headers_added = { "wsp:metaParametry" => 
                      { "wsp:identyfikatorStanowiska" => responseToken.stanowisko_first } 
                    }

    mess_body = { 
      "mt:tytul" => tytul,
      "mt:terminRealizacji" => termin_realizacji,
      "mt:identyfikatorKategoriiSprawy" => identyfikator_kategorii_sprawy,
      "mt:adnotacja" => {
        "wsp:tytul" => adnotacja,
        "wsp:tresc" => ""
        },
      "mt:komorkaISymbol" => {
        "mt:identyfikatorKomorkiOrganizacyjnej" => responseToken.identyfikator_komorki_organizacyjnej_first,
        "mt:symbolJRWA" => symbol_jrwa
        },
      "mt:znakSprawyGrupujacej" => znak_sprawy_grupujacej
      }

    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "http://testesod.uke.gov.pl/wsdl/sprawy/ws/sprawy.wsdl",
      endpoint: "http://testesod.uke.gov.pl/uslugi.php/sprawy/handle",
      namespaces: { "xmlns:mt" => "http://www.dokus.pl/sprawy/mt",
                    "xmlns:ws" => "http://www.dokus.pl/sprawy/ws/utworzSprawe", 
                    "xmlns:wsp" => "http://www.dokus.pl/wspolne" },
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
      soap_version: 2,
      # Tutaj musi być podawane Login i Pobrany Token, a nie hash_password
      #wsse_auth: [my_login, "7584b77307868d6fde1dd9dbad28f2403d57d8d19826d13932aca4fad9fa88a41df1cddb28e0aad11b607e0b756da42cb02f2ff2a46809c0b9df6647f3d6a8fc"]
      wsse_auth: [esod_user_email, responseToken.token_string],
      soap_header: headers_added
    )


    puts '-----------------------------------------------------'
    puts 'przerywam: insert_data_to_esod_and_update_self'
    puts '-----------------------------------------------------'

    return

    response = client.call(:utworz_sprawe,  message: mess_body )

    if response.success?
      #puts JSON.pretty_generate(response.to_json)
      puts '-----------------------------------------------------'
      puts response.to_json
      puts '-----------------------------------------------------'
#      {"utworz_sprawe_response":
#        { "nrid":"1172",
#          "znak":"OGD.5432.1.2016",
#          "znak_sprawy_grupujacej":null,
#          "symbol_jrwa":"5432",
#          "tytul":"11/2016/A, UKE Opole",
#          "termin_realizacji":"2016-05-01 00:00:00",
#          "identyfikator_stanowiska_referenta":"2495"
#        }
#      }

      esod_matter = Esod::Matter.create!(
        nrid: response.to_hash[:utworz_sprawe_response][:nrid],
        znak: response.to_hash[:utworz_sprawe_response][:znak],
        znak_sprawy_grupujacej: response.to_hash[:utworz_sprawe_response][:znak_sprawy_grupujacej],
        symbol_jrwa: response.to_hash[:utworz_sprawe_response][:symbol_jrwa],
        tytul: response.to_hash[:utworz_sprawe_response][:znak],
        termin_realizacji: response.to_hash[:utworz_sprawe_response][:termin_realizacji],
          identyfikator_kategorii_sprawy: 47, # response.to_hash[:utworz_sprawe_response][:identyfikator_kategorii_sprawy],
          adnotacja: "",
        identyfikator_stanowiska_referenta: response.to_hash[:utworz_sprawe_response][:identyfikator_stanowiska_referenta],
          czy_otwarta: true,
          data_utworzenia: "2016-03-30 07:35:52",
          data_modyfikacji: "2016-03-30 07:35:52",
          initialized_from_esod: true
      )  unless esod_matter = Esod::Matter.where(tytul: "#{number}, #{place_exam}" ).any?

      self.esod_matter = esod_matter 
    end


    rescue Savon::HTTPError => error
      puts '----------Savon::HTTPError => error error.http.code----------------'
      puts error.http.code
      puts '----------fault-------------------'
      puts error.to_hash[:fault][:faultcode]
      puts error.to_hash[:fault][:faultstring]
      puts error.to_hash[:fault][:detail]
      puts '-------------------------------------------------------------------'
      #raise

    rescue Savon::SOAPFault => error
      puts '----------Savon::SOAPFault => error error.http.code----------------'
      puts error.http.code
      puts '----------fault-------------------'
      puts error.to_hash[:fault][:faultcode]
      puts error.to_hash[:fault][:faultstring]
      puts error.to_hash[:fault][:detail]
      puts '-------------------------------------------------------------------'
      #raise CustomError, fault_code
      #raise
  end

  def exam_insert_data_to_esod
    jrwa = Esodes::esod_matter_service_jrwa(category).to_s

    # szukaj sprawy z poprzednim tutułem jezeli nie dokonano zmian
    if number == number_was && place_exam == place_exam_was
      esod_matter = Esod::Matter.where(tytul: "#{number_was}, #{place_exam_was}", symbol_jrwa: "#{jrwa}")
    else 
      # jezeli nie znalazleś, to szukaj z nowym tytułem
      esod_matter = Esod::Matter.where(tytul: "#{number}, #{place_exam}", symbol_jrwa: "#{jrwa}") unless esod_matter.present?
    end

    return



    responseToken = Esod::Token.new(self.user.email, self.user.esod_encryped_password)


    headers_added = { "wsp:metaParametry" => 
                      { "wsp:identyfikatorStanowiska" => responseToken.stanowisko_first } 
                    }

    mess_body = { 
      "mt:tytul" => "#{number}, #{place_exam}",
      "mt:terminRealizacji" => "#{date_exam}",
      "mt:identyfikatorKategoriiSprawy" => Rails.application.secrets["esod_exam_{category.downcase}_identyfikator_kategorii_sprawy"],
      "mt:adnotacja" => {
        "wsp:tytul" => "NETPAR2015 - uwagi",
        "wsp:tresc" => "#{note}"
        },
      "mt:komorkaISymbol" => {
        "mt:identyfikatorKomorkiOrganizacyjnej" => responseToken.identyfikator_komorki_organizacyjnej_first,
        "mt:symbolJRWA" => "#{jrwa}"
        },
      "mt:znakSprawyGrupujacej" => ""
      }

    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "http://testesod.uke.gov.pl/wsdl/sprawy/ws/sprawy.wsdl",
      endpoint: "http://testesod.uke.gov.pl/uslugi.php/sprawy/handle",
      namespaces: { "xmlns:mt" => "http://www.dokus.pl/sprawy/mt",
                    "xmlns:ws" => "http://www.dokus.pl/sprawy/ws/utworzSprawe", 
                    "xmlns:wsp" => "http://www.dokus.pl/wspolne" },
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
      soap_version: 2,
      # Tutaj musi być podawane Login i Pobrany Token, a nie hash_password
      #wsse_auth: [my_login, "7584b77307868d6fde1dd9dbad28f2403d57d8d19826d13932aca4fad9fa88a41df1cddb28e0aad11b607e0b756da42cb02f2ff2a46809c0b9df6647f3d6a8fc"]
      wsse_auth: [self.user.email, responseToken.token_string],
      soap_header: headers_added
    )

    response = client.call(:utworz_sprawe,  message: mess_body )

    if response.success?
      #puts JSON.pretty_generate(response.to_json)
      puts '-----------------------------------------------------'
      puts response.to_json
      puts '-----------------------------------------------------'
#      {"utworz_sprawe_response":
#        { "nrid":"1172",
#          "znak":"OGD.5432.1.2016",
#          "znak_sprawy_grupujacej":null,
#          "symbol_jrwa":"5432",
#          "tytul":"11/2016/A, UKE Opole",
#          "termin_realizacji":"2016-05-01 00:00:00",
#          "identyfikator_stanowiska_referenta":"2495"
#        }
#      }

      esod_matter = Esod::Matter.create!(
        nrid: response.to_hash[:utworz_sprawe_response][:nrid],
        znak: response.to_hash[:utworz_sprawe_response][:znak],
        znak_sprawy_grupujacej: response.to_hash[:utworz_sprawe_response][:znak_sprawy_grupujacej],
        symbol_jrwa: response.to_hash[:utworz_sprawe_response][:symbol_jrwa],
        tytul: response.to_hash[:utworz_sprawe_response][:znak],
        termin_realizacji: response.to_hash[:utworz_sprawe_response][:termin_realizacji],
          identyfikator_kategorii_sprawy: 47, # response.to_hash[:utworz_sprawe_response][:identyfikator_kategorii_sprawy],
          adnotacja: "",
        identyfikator_stanowiska_referenta: response.to_hash[:utworz_sprawe_response][:identyfikator_stanowiska_referenta],
          czy_otwarta: true,
          data_utworzenia: "2016-03-30 07:35:52",
          data_modyfikacji: "2016-03-30 07:35:52",
          initialized_from_esod: true
      )  unless esod_matter = Esod::Matter.where(tytul: "#{number}, #{place_exam}" ).any?

      self.esod_matter = esod_matter 
    end


    rescue Savon::HTTPError => error
      puts '----------Savon::HTTPError => error error.http.code----------------'
      puts error.http.code
      puts '----------fault-------------------'
      puts error.to_hash[:fault][:faultcode]
      puts error.to_hash[:fault][:faultstring]
      puts error.to_hash[:fault][:detail]
      puts '-------------------------------------------------------------------'
      #raise

    rescue Savon::SOAPFault => error
      puts '----------Savon::SOAPFault => error error.http.code----------------'
      puts error.http.code
      puts '----------fault-------------------'
      puts error.to_hash[:fault][:faultcode]
      puts error.to_hash[:fault][:faultstring]
      puts error.to_hash[:fault][:detail]
      puts '-------------------------------------------------------------------'
      #raise CustomError, fault_code
      #raise
  end

  def exam_has_links
    analize_value = true
    if self.certificates.any? 
      errors[:base] << "Nie można usunąć Sesji do której są przypisane Świadectwa."
      analize_value = false
    end
    if self.examinations.any? 
      errors[:base] << "Nie można usunąć Sesji do której są przypisane Osoby Egzaminowane."
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
  scope :finder_esod_matter, ->(q, iks, jrwa) { where( create_sql_string("#{q}", "#{iks}", "#{jrwa}") ) }
 
  # Method create SQL query string for finder select2: "exam_select"
  # * parameters   :
  #   * +jrwa_scope+ -> jrwa of exam %w(l m r). 
  #   * +query_str+ -> string for search. 
  #   Ex.: "M/2015 war"
  # * result   :
  #   * +sql_string+ -> string for SQL WHERE... 
  #
  def self.create_sql_string(query_str, iks_array, jrwa_array)
    #JSON.parse("[1,2,3,4,5]") => [1, 2, 3, 4, 5]
    #[1, 2, 3, 4, 5].join(", ") => "1, 2, 3, 4, 5"
    iks_query = JSON.parse(iks_array).join(", ") 
    jrwa_query = JSON.parse(jrwa_array).map {|v| "'#{v}'" }.join(", ") 
    "(esod_matters.identyfikator_kategorii_sprawy IN (#{iks_query})) AND (esod_matters.symbol_jrwa IN (#{jrwa_query})) AND " + query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
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
    "(" + %w(esod_matters.znak esod_matters.tytul to_char(esod_matters.termin_realizacji,'YYYY-mm-dd') ).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end


  def save_to_esod(user_email, esod_user_pass)
    responseToken = Esod::Token.new(user_email, esod_user_pass)

    headers_added = { "wsp:metaParametry" => 
                      { "wsp:identyfikatorStanowiska" => responseToken.stanowisko_first } 
                    }

    mess_body = { 
      "mt:tytul" => self.tytul,
      "mt:terminRealizacji" => self.termin_realizacji,
      "mt:identyfikatorKategoriiSprawy" => self.identyfikator_kategorii_sprawy,
      "mt:adnotacja" => {
        "wsp:tytul" => "Założenie sprawy",
        "wsp:tresc" => "test" #self.adnotacja
        },
      "mt:komorkaISymbol" => {
        "mt:identyfikatorKomorkiOrganizacyjnej" => responseToken.identyfikator_komorki_organizacyjnej_first,
        "mt:symbolJRWA" => self.symbol_jrwa
        },
      "mt:znakSprawyGrupujacej" => ""
      }

    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "http://testesod.uke.gov.pl/wsdl/sprawy/ws/sprawy.wsdl",
      endpoint: "http://testesod.uke.gov.pl/uslugi.php/sprawy/handle",
      namespaces: { "xmlns:mt" => "http://www.dokus.pl/sprawy/mt",
                    "xmlns:ws" => "http://www.dokus.pl/sprawy/ws/utworzSprawe", 
                    "xmlns:wsp" => "http://www.dokus.pl/wspolne" },
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
      soap_version: 2,
      # Tutaj musi być podawane Login i Pobrany Token, a nie hash_password
      #wsse_auth: [my_login, "7584b77307868d6fde1dd9dbad28f2403d57d8d19826d13932aca4fad9fa88a41df1cddb28e0aad11b607e0b756da42cb02f2ff2a46809c0b9df6647f3d6a8fc"]
      wsse_auth: [user_email, responseToken.token_string],
      soap_header: headers_added
    )

    response = client.call(:utworz_sprawe,  message: mess_body )

    if response.success?
      #puts JSON.pretty_generate(response.to_json)
      puts response.to_json
#      {"utworz_sprawe_response":
#        { "nrid":"1172",
#          "znak":"OGD.5432.1.2016",
#          "znak_sprawy_grupujacej":null,
#          "symbol_jrwa":"5432",
#          "tytul":"11/2016/A, UKE Opole",
#          "termin_realizacji":"2016-05-01 00:00:00",
#          "identyfikator_stanowiska_referenta":"2495"
#        }
#      }

    end

    rescue Savon::HTTPError => error
      puts '----------Savon::HTTPError => error error.http.code----------------'
      puts error.http.code
      puts '----------fault-------------------'
      puts error.to_hash[:fault][:faultcode]
      puts error.to_hash[:fault][:faultstring]
      puts error.to_hash[:fault][:detail]
      puts '-------------------------------------------------------------------'
      #raise

    rescue Savon::SOAPFault => error
      puts '----------Savon::SOAPFault => error error.http.code----------------'
      puts error.http.code
      puts '----------fault-------------------'
      puts error.to_hash[:fault][:faultcode]
      puts error.to_hash[:fault][:faultstring]
      puts error.to_hash[:fault][:detail]
      puts '-------------------------------------------------------------------'
      #raise CustomError, fault_code
      #raise

  end




end
