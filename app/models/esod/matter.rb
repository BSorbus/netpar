include  ActionView::Helpers::TextHelper
require 'esodes'

class Esod::Matter < ActiveRecord::Base
  belongs_to :exam
  belongs_to :examination
  belongs_to :certificate

  has_many :esod_matter_notes, class_name: 'Esod::MatterNote', primary_key: 'id', foreign_key: 'esod_matter_id'
  accepts_nested_attributes_for :esod_matter_notes,
                                reject_if: proc { |attributes| attributes['tytul'].blank? },
                                allow_destroy: true
  validates_associated :esod_matter_notes


  has_many :esod_incoming_letters_matters, class_name: 'Esod::IncomingLettersMatter', foreign_key: :esod_matter_id 
  has_many :esod_incoming_letters, through: :esod_incoming_letters_matters, primary_key: :esod_incoming_letter_id

  has_many :esod_outgoing_letters_matters, class_name: 'Esod::OutgoingLettersMatter', foreign_key: :esod_matter_id 
  has_many :esod_outgoing_letters, through: :esod_outgoing_letters_matters, primary_key: :esod_outgoing_letter_id

  has_many :esod_internal_letters_matters, class_name: 'Esod::InternalLettersMatter', foreign_key: :esod_matter_id 
  has_many :esod_internal_letters, through: :esod_internal_letters_matters, primary_key: :esod_internal_letter_id

  has_many :works, as: :trackable, source_type: 'Esod::Matter'

  #validates :tytul, presence: true, length: { in: 0..254 }

  # callbacks
  before_save :insert_data_to_esod_and_update_self, on: :create, if: "initialized_from_esod == false"
  #before_save :update_esod_matter, unless: "esod_matter_id.blank?"



  def fullname
    "#{znak}, #{truncate(tytul, length: 85)}, #{termin_realizacji}, [#{iks_name}]}"
  end

  def fullname_and_id
    "#{znak}, [#{iks_name}] (#{id})"
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

  def flat_all_matter_notes
    self.esod_matter_notes.order(:id).flat_map {|row| row.tytul }.join(' <br>').html_safe
  end

  def flat_all_incoming_letters_matters
    self.esod_incoming_letters_matters.order(:id).flat_map {|row| "#{row.sygnatura} [#{row.esod_incoming_letter.numer_ewidencyjny}] (P)" }.join(' <br>').html_safe
  end

  def flat_all_outgoing_letters_matters
    self.esod_outgoing_letters_matters.order(:id).flat_map {|row| "#{row.sygnatura} [#{row.esod_outgoing_letter.numer_ewidencyjny}] (W)" }.join(' <br>').html_safe
  end

  def flat_all_internal_letters_matters
    self.esod_internal_letters_matters.order(:id).flat_map {|row| "#{row.sygnatura} [#{row.esod_internal_letter.numer_ewidencyjny}] (I)" }.join(' <br>').html_safe
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

  def insert_data_to_esod_and_update_self
#    esod_user = User.find_by(id: netpar_user)
#    esod_user_email = esod_user.email
#    esod_user_pass =  esod_user.esod_encryped_password
#    responseToken = Esod::Token.new(esod_user_email, esod_user_pass)
#
#    headers_added = { "wsp:metaParametry" => 
#                      { "wsp:identyfikatorStanowiska" => responseToken.stanowiska.first[:nrid] } 
#                    }

    headers_added = { "wsp:metaParametry" => 
                      { "wsp:identyfikatorStanowiska" => Esodes::EsodTokenData.token_stanowiska.first[:nrid] } 
                    }

    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Esodes::ESOD_API_SERVER}/wsdl/sprawy/ws/sprawy.wsdl",
      endpoint: "#{Esodes::ESOD_API_SERVER}/uslugi.php/sprawy/handle",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:mt" => "http://www.dokus.pl/sprawy/mt",
                    "xmlns:ws" => "http://www.dokus.pl/sprawy/ws", 
                    "xmlns:wsp" => "http://www.dokus.pl/wspolne",
                    "xmlns:ns1" => "http://www.dokus.pl/wspolne", 
                    "xmlns:ns2" => "http://www.dokus.pl/sprawy/mt", 
                    "xmlns:ns3" => "http://www.dokus.pl/sprawy/ws" },
      namespace_identifier: :ws, #"xmlns:ws" => "http://www.dokus.pl/sprawy/ws/utworzSprawe", 
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
      soap_version: 2,
      # Tutaj musi być podawane Login i Pobrany Token, a nie hash_password
      #wsse_auth: [my_login, "7584b77307868d6fde1dd9dbad28f2403d57d8d19826d13932aca4fad9fa88a41df1cddb28e0aad11b607e0b756da42cb02f2ff2a46809c0b9df6647f3d6a8fc"]
#      wsse_auth: [esod_user_email, responseToken.token_string],
      wsse_auth: [Esodes::EsodTokenData.netpar_user.email, Esodes::EsodTokenData.token_string],
      soap_header: headers_added
    )

#response.success?     # => false
#response.soap_fault?  # => true
#response.http_error?  # => false

    message_body = { 
      "mt:tytul" => "#{self.tytul}",
      "mt:terminRealizacji" => "#{self.termin_realizacji}",
      "mt:identyfikatorKategoriiSprawy" => "#{self.identyfikator_kategorii_sprawy}",
      "mt:adnotacja" => {
        "wsp:tytul" => self.esod_matter_notes.present? ? "#{self.esod_matter_notes.last.tytul}" : "",
        "wsp:tresc" => self.esod_matter_notes.present? ? "#{self.esod_matter_notes.last.tresc}" : ""
        },
      "mt:komorkaISymbol" => {
        "mt:identyfikatorKomorkiOrganizacyjnej" => "#{Esodes::EsodTokenData.token_stanowiska.first[:identyfikator_komorki_organizacyjnej]}",
        "mt:symbolJRWA" => "#{self.symbol_jrwa}"
        },
      "mt:znakSprawyGrupujacej" => "#{self.znak_sprawy_grupujacej}"
      }

    response = client.call(:utworz_sprawe,  message: message_body )

    if response.success?
      self.data_utworzenia = response.xpath('//ns1:dataUtworzenia').text
      self.identyfikator_osoby_tworzacej = response.xpath('//ns1:identyfikatorOsobyTworzacej').text
      self.data_modyfikacji = response.xpath('//ns1:dataModyfikacji').text
      self.identyfikator_osoby_modyfikujacej = response.xpath('//ns1:identyfikatorOsobyModyfikujacej').text
      self.nrid = response.xpath('//ns2:nrid').text
      self.znak = response.xpath('//ns2:znak').text
      self.znak_sprawy_grupujacej = response.xpath('//ns2:znak_sprawy_grupujacej').text
      self.identyfikator_stanowiska_referenta = response.xpath('//ns2:identyfikatorStanowiskaReferenta').text
    end

    rescue Savon::HTTPError => error
      #Logger.log error.http.code
      puts '==================================================================='
      puts '      ----- Savon::HTTPError => error error.http.code -----'
      puts "error.http.code: #{error.http.code}"
      puts "      faultcode: #{error.to_hash[:fault][:faultcode]}"
      puts "    faultstring: #{error.to_hash[:fault][:faultstring]}"
      puts "         detail: #{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      #raise

    rescue Savon::SOAPFault => error
      #Logger.log error.http.code
      puts '==================================================================='
      puts '      ----- Savon::SOAPFault => error error.http.code -----'
      puts "error.http.code: #{error.http.code}"
      puts "      faultcode: #{error.to_hash[:fault][:faultcode]}"
      puts "    faultstring: #{error.to_hash[:fault][:faultstring]}"
      puts "         detail: #{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      #raise CustomError, fault_code
      #raise

    rescue Savon::InvalidResponseError => error
      #Logger.log error.http.code
      puts '==================================================================='
      puts ' ----- Savon::InvalidResponseError => error error.http.code -----'
      puts "error.http.code: #{error.http.code}"
      puts "      faultcode: #{error.to_hash[:fault][:faultcode]}"
      puts "    faultstring: #{error.to_hash[:fault][:faultstring]}"
      puts "         detail: #{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      #raise CustomError, fault_code
      #raise
      
  end


  def self.get_wyszukaj_sprawy_referenta(data_start, data_end)
    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Esodes::ESOD_API_SERVER}/wsdl/sprawy/ws/sprawy.wsdl",
      endpoint: "#{Esodes::ESOD_API_SERVER}/uslugi.php/sprawy/handle",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:mt" => "http://www.dokus.pl/sprawy/mt",
                    "xmlns:ws" => "http://www.dokus.pl/sprawy/ws", 
                    "xmlns:wsp" => "http://www.dokus.pl/wspolne",
                    "xmlns:ns1" => "http://www.dokus.pl/wspolne", 
                    "xmlns:ns2" => "http://www.dokus.pl/sprawy/mt", 
                    "xmlns:ns3" => "http://www.dokus.pl/sprawy/ws" },
      namespace_identifier: :ws, #"xmlns:ws" => "http://www.dokus.pl/sprawy/ws/utworzSprawe", 
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
      soap_version: 2,
      wsse_auth: [Esodes::EsodTokenData.netpar_user.email, Esodes::EsodTokenData.token_string],
      soap_header: { "wsp:metaParametry" => 
                      { "wsp:identyfikatorStanowiska" => Esodes::EsodTokenData.token_stanowiska.first[:nrid] } 
                    }
    )

    message_body = { 
      "mt:sprawyPoDacie" => "#{data_start}",
      "mt:sprawySprzedDaty" => "#{data_end}"
    }

    response = client.call(:wyszukaj_sprawy_referenta,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='wyszukajSprawyReferentaResponse']").each do |resp|
        resp.xpath("./*[local-name()='sprawa']").each do |row|
          puts '----------------------------------------------------------------'
          puts '-------------------         SPRAWA           -------------------'
          puts '----------------------------------------------------------------'
          puts row.xpath("./*[local-name()='nrid']").text
          puts row.xpath("./*[local-name()='dataUtworzenia']").text
          puts row.xpath("./*[local-name()='znak']").text
          puts row.xpath("./*[local-name()='symbolJRWA']").text
          puts row.xpath("./*[local-name()='tytul']").text
          puts row.xpath("./*[local-name()='terminRealizacji']").text
          puts row.xpath("./*[local-name()='identyfikatorKategoriiSprawy']").text
          puts row.xpath("./*[local-name()='adnotacja']").text
          puts '----------------------------------------------------------------'
          
          self.get_wyszukaj_dokumenty_sprawy(row.xpath("./*[local-name()='nrid']").text)
        end
      end
    end

  end



  def self.get_wyszukaj_dokumenty_sprawy(id)
    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Esodes::ESOD_API_SERVER}/wsdl/sprawy/ws/sprawy.wsdl",
      endpoint: "#{Esodes::ESOD_API_SERVER}/uslugi.php/sprawy/handle",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:mt" => "http://www.dokus.pl/sprawy/mt",
                    "xmlns:ws" => "http://www.dokus.pl/sprawy/ws", 
                    "xmlns:wsp" => "http://www.dokus.pl/wspolne",
                    "xmlns:ns1" => "http://www.dokus.pl/sprawy/mt", 
                    "xmlns:ns2" => "http://www.dokus.pl/sprawy", 
                    "xmlns:ns3" => "http://www.dokus.pl/dokumenty/mt/dokumenty_przychodzace", 
                    "xmlns:ns4" => "http://www.dokus.pl/slowniki/mt/slowniki", 
                    "xmlns:ns5" => "http://www.dokus.pl/sprawy/ws" },
      namespace_identifier: :ws, #"xmlns:ws" => "http://www.dokus.pl/sprawy/ws/utworzSprawe", 
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
      soap_version: 2,
      wsse_auth: [Esodes::EsodTokenData.netpar_user.email, Esodes::EsodTokenData.token_string],
      soap_header: { "wsp:metaParametry" => 
                      { "wsp:identyfikatorStanowiska" => Esodes::EsodTokenData.token_stanowiska.first[:nrid] } 
                    }
    )

    message_body = { 
      "mt:nrid" => "#{id}"
    }

    response = client.call(:pobierz_dokumenty_sprawy,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='pobierzDokumentySprawyResponse']").each do |resp|
        resp.xpath("./*[local-name()='dokument']").each do |dok|
          puts dok.xpath("./*[local-name()='sygnatura']").text
          dok.xpath("./*[local-name()='dokumentPrzychodzacy']").each do |row|
            puts '++++++++++++++++   DOKUMENT PRZYCHODZACY    ++++++++++++++++++++'
            puts row.xpath("./*[local-name()='dataUtworzenia']").text
            puts row.xpath("./*[local-name()='identyfikatorOsobyTworzacej']").text
            puts row.xpath("./*[local-name()='dataModyfikacji']").text
            puts row.xpath("./*[local-name()='identyfikatorOsobyModyfikujacej']").text
            puts row.xpath("./*[local-name()='nrid']").text
            puts row.xpath("./*[local-name()='numerEwidencyjny']").text
            puts row.xpath("./*[local-name()='tytul']").text
            puts row.xpath("./*[local-name()='dataPisma']").text
            puts row.xpath("./*[local-name()='dataNadania']").text
            puts row.xpath("./*[local-name()='dataWplyniecia']").text
            puts row.xpath("./*[local-name()='znakPismaWplywajacego']").text
            puts row.xpath("./*[local-name()='identyfikatorTypuDCMD']").text
            puts row.xpath("./*[local-name()='identyfikatorRodzajuDokumentu']").text
            puts row.xpath("./*[local-name()='identyfikatorSposobuPrzeslania']").text
            puts row.xpath("./*[local-name()='znakPismaWplywajacego']").text
            puts '         --- nadawca:'
            row.xpath("./*[local-name()='nadawca']").each do |nad|
              puts '            --- osoba:'
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='dataUtworzenia']").text
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='identyfikatorOsobyTworzacej']").text
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='dataModyfikacji']").text
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='identyfikatorOsobyModyfikujacej']").text
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='nrid']").text
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='imie']").text
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='nazwisko']").text
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='pesel']").text
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='rodzaj']").xpath("./*[local-name()='nrid']").text
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='rodzaj']").xpath("./*[local-name()='nazwa']").text
              puts nad.xpath("./*[local-name()='osoba']").xpath("./*[local-name()='rodzaj']").xpath("./*[local-name()='rodzaj_epuap']").text
              puts '            -------'
              puts '            --- adres:'
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='dataUtworzenia']").text
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='identyfikatorOsobyTworzacej']").text
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='dataModyfikacji']").text
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='identyfikatorOsobyModyfikujacej']").text
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='nrid']").text
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='miasto']").text
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='kodPocztowy']").text
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='ulica']").text
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='numerBudynku']").text
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='numerLokalu']").text
              puts nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='panstwo']").text
              puts '            -------'
            end
            puts '         ------------'
            puts row.xpath("./*[local-name()='pelnaWersjaCyfrowa']").text
            puts row.xpath("./*[local-name()='naturalnyElektroniczny']").text
            puts row.xpath("./*[local-name()='uwagi']").text
            puts '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
          end

          dok.xpath("./*[local-name()='dokumentWychodzacy']").each do |row|
            puts '++++++++++++++++    DOKUMENT WYCHODZACY     ++++++++++++++++++++'
            puts row.xpath("./*[local-name()='nrid']").text
            puts row.xpath("./*[local-name()='numerEwidencyjny']").text
            puts row.xpath("./*[local-name()='tytul']").text
            puts '         --- wysyłka:'
            puts row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='identyfikatorAdresu']").text
            puts row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='identyfikatorSposobuWysylki']").text
            puts row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='dataWyslania']").text
            puts row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='czyAdresatGlowny']").text
            puts '         -----------'
            puts row.xpath("./*[local-name()='identyfkatorRodzajuDokumentuWychodzacego']").text
            puts row.xpath("./*[local-name()='dataPisma']").text
            puts row.xpath("./*[local-name()='numerWersji']").text
            puts row.xpath("./*[local-name()='czyPelnaWersjaCyfrowa']").text
            puts '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
          end
          dok.xpath("./*[local-name()='dokumentWewnetrzny']").each do |row|
            puts '++++++++++++++++    DOKUMENT WEWNĘTRZNY     ++++++++++++++++++++'
            puts row.xpath("./*[local-name()='nrid']").text
            puts row.xpath("./*[local-name()='numerEwidencyjny']").text
            puts row.xpath("./*[local-name()='tytul']").text
            puts row.xpath("./*[local-name()='uwagi']").text
            puts row.xpath("./*[local-name()='identyfikatorRodzajuDokumentuWewnetrznego']").text
            puts row.xpath("./*[local-name()='identyfikatorTypuDCMD']").text
            puts row.xpath("./*[local-name()='identyfikatorDostepnosciDokumentu']").text
            puts row.xpath("./*[local-name()='czyPelnaWersjaCyfrowa']").text
            puts '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
          end

        end
      end
    end

    rescue 
      logger.fatal "ERROR!!! "

  end



end
