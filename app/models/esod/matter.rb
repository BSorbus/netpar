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
  before_save :insert_data_to_esod_and_update_self, if: "((self.new_record?) && (initialized_from_esod == false))"
  #before_save :update_esod_matter, unless: "esod_matter_id.blank?"



  def fullname
    "#{znak}, #{truncate(tytul, length: 85)}, #{termin_realizacji}, [#{iks_name}]"
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

  def znak_with_padlock
    self.czy_otwarta ? "#{znak}" : "#{znak} &nbsp;<div class='glyphicon glyphicon-lock'></div>".html_safe
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
     my_token = Esodes::EsodTokenData.token_string

    if Esodes::EsodTokenData.response_token_errors.present? 
      Esodes::EsodTokenData.response_token_errors.each do |err|
        errors.add(:base, "#{err}")
      end
      return false
    end

    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Rails.application.secrets[:wso2ei_url]}/services/SprawaESODUsluga?wsdl",
      endpoint: "#{Rails.application.secrets[:wso2ei_url]}/services/SprawaESODUsluga.SprawaESODUslugaHttpsSoap11Endpoint",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:spr" => "http://sprawaESOD.uslugi.epl.uke.gov.pl/"
                  },
      env_namespace: :soapenv,
      namespace_identifier: :spr, 
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug, # [:debug, :info, :warn, :error, :fatal]
      log: true,
      pretty_print_xml: true,
      soap_version: 1,
      wsse_timestamp: true,
      ssl_verify_mode: :none,
      headers: { "Authorization" => "Basic #{Esodes::base64_user_and_pass}" },
      wsse_auth: [Esodes::EsodTokenData.netpar_user.email, my_token],
      soap_header: { "spr:metaParametry" => 
                      { "spr:identyfikatorStanowiska" => Esodes::EsodTokenData.token_stanowiska.first[:nrid] } 
                    }
    )

#response.success?     # => false
#response.soap_fault?  # => true
#response.http_error?  # => false

    message_body = { 
      "parametryOperacjiUtworzSprawe" => {
        "identyfikatorKategoriiSprawy" => "#{self.identyfikator_kategorii_sprawy}",
        "opis" => "#{self.tytul}",
        "terminRealizacji" => "#{self.termin_realizacji}",
        "adnotacja" => {
          "tresc" => self.esod_matter_notes.present? ? "#{self.esod_matter_notes.last.tresc}" : "",
          "tytul" => self.esod_matter_notes.present? ? "#{self.esod_matter_notes.last.tytul}" : ""
        },
        "komorkaISymbol" => {
          "identyfikatorKomorkiOrganizacyjnej" => "#{Esodes::EsodTokenData.token_stanowiska.first[:identyfikator_komorki_organizacyjnej]}",
          "symbolJRWA" => {
            "symbolJRWA" => "#{self.symbol_jrwa}"
          }
        }
      }
    }

    response = client.call(:utworz_sprawe,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='return']").each do |ret|
        ret.xpath("//*[local-name()='sprawa']").each do |row|
          self.czy_otwarta = row.xpath('//czyOtwarta').text
          self.data_utworzenia = row.xpath('//dataRejestracji').text
          self.data_modyfikacji = row.xpath('//dataAktualizacji').text
          self.nrid = row.xpath('//nrid').text
          self.znak = row.xpath('//znakSprawy').text
          self.identyfikator_stanowiska_referenta = Esodes::EsodTokenData.token_stanowiska.first[:nrid]
        end
      end
    end


    rescue Savon::HTTPError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\matter.rb', 
                              function:  "insert_data_to_esod_and_update_self", 
                              soap_function:  "utworz_sprawe", 
                              base_obj:   self )
      false

    rescue Savon::SOAPFault => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\matter.rb', 
                              function:  "insert_data_to_esod_and_update_self", 
                              soap_function:  "utworz_sprawe", 
                              base_obj:   self )
      false

    rescue Savon::InvalidResponseError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\matter.rb', 
                              function:  "insert_data_to_esod_and_update_self", 
                              soap_function:  "utworz_sprawe", 
                              base_obj:   self )
      false

    rescue Savon::Error => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\matter.rb', 
                              function:  "insert_data_to_esod_and_update_self", 
                              soap_function:  "utworz_sprawe", 
                              base_obj:   self )
      false

    rescue SocketError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\matter.rb', 
                              function:  "insert_data_to_esod_and_update_self", 
                              soap_function:  "utworz_sprawe", 
                              base_obj:   self )
      false

    rescue => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\matter.rb', 
                              function:  "insert_data_to_esod_and_update_self", 
                              soap_function:  "utworz_sprawe", 
                              base_obj:   self )
      false

  end


  def self.get_wyszukaj_sprawy_referenta(data_start, data_end)
    my_token = Esodes::EsodTokenData.token_string

    if Esodes::EsodTokenData.response_token_errors.present? 
      Esodes::EsodTokenData.response_token_errors.each do |err|
        puts "#{err}"
      end
      return false
    end

    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Rails.application.secrets[:wso2ei_url]}/services/SprawaESODUsluga?wsdl",
      endpoint: "#{Rails.application.secrets[:wso2ei_url]}/services/SprawaESODUsluga.SprawaESODUslugaHttpsSoap11Endpoint",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:spr" => "http://sprawaESOD.uslugi.epl.uke.gov.pl/"
                  },
      env_namespace: :soapenv,
      namespace_identifier: :spr, 
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      soap_version: 1,
      wsse_timestamp: true,
      ssl_verify_mode: :none,
      headers: { "Authorization" => "Basic #{Esodes::base64_user_and_pass}" },
      wsse_auth: [Esodes::EsodTokenData.netpar_user.email, my_token],
      soap_header: { "spr:metaParametry" => 
                      { "spr:identyfikatorStanowiska" => Esodes::EsodTokenData.token_stanowiska.first[:nrid] } 
                    }
    )

    message_body = { 
      "parametryOperacjiWyszukajSpraweReferenta" => {
        "sprawyPoDacie" => "#{data_start}",
        "sprawySprzedDaty" => "#{data_end}"
      }
    }

    response = client.call(:wyszukaj_sprawe_referenta,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='wyszukajSpraweReferentaResponse']").each do |resp|
        resp.xpath("//*[local-name()='return']").each do |ret|
          ret.xpath("./*[local-name()='sprawy']").each do |row|
            # pobieraj tylko sprawy z określonego JRWA i tylko z określoną kategorią sprawy
            if Esodes::JRWA_ALL.join(' ').include?(row.xpath("./*[local-name()='symbolJRWA']").xpath("./*[local-name()='symbolJRWA']").text) && 
                row.xpath("./*[local-name()='identyfikatorKategoriiSprawy']").text.present?
              @matter = Esod::Matter.find_by(nrid: row.xpath("./*[local-name()='nrid']").text)
              if @matter.present?
                @matter.znak                                = row.xpath("./*[local-name()='znakSprawy']").text,
                @matter.symbol_jrwa                         = row.xpath("./*[local-name()='symbolJRWA']").xpath("./*[local-name()='symbolJRWA']").text, 
                @matter.tytul                               = row.xpath("./*[local-name()='opis']").text, 
                @matter.termin_realizacji                   = row.xpath("./*[local-name()='terminRealizacji']").text,
                @matter.identyfikator_kategorii_sprawy      = row.xpath("./*[local-name()='identyfikatorKategoriiSprawy']").text, 
                @matter.identyfikator_stanowiska_referenta  = Esodes::EsodTokenData.token_stanowiska.first[:nrid], 
                @matter.czy_otwarta                         = row.xpath("./*[local-name()='czyOtwarta']").text, 
                @matter.data_utworzenia                     = row.xpath("./*[local-name()='dataRejestracji']").text,
                @matter.data_modyfikacji                    = row.xpath("./*[local-name()='dataAktualizacji']").text,
                @matter.save! if @matter.changed?
              else 
                @matter = Esod::Matter.create(
                  nrid:                               row.xpath("./*[local-name()='nrid']").text,  
                  znak:                               row.xpath("./*[local-name()='znakSprawy']").text,
                  symbol_jrwa:                        row.xpath("./*[local-name()='symbolJRWA']").xpath("./*[local-name()='symbolJRWA']").text, 
                  tytul:                              row.xpath("./*[local-name()='opis']").text, 
                  termin_realizacji:                  row.xpath("./*[local-name()='terminRealizacji']").text,
                  identyfikator_kategorii_sprawy:     row.xpath("./*[local-name()='identyfikatorKategoriiSprawy']").text, 
                  adnotacja:                          "", #row[:adnotacja], 
                  identyfikator_stanowiska_referenta: Esodes::EsodTokenData.token_stanowiska.first[:nrid], 
                  czy_otwarta:                        row.xpath("./*[local-name()='czyOtwarta']").text, 
                  data_utworzenia:                    row.xpath("./*[local-name()='dataRejestracji']").text,
                  data_modyfikacji:                   row.xpath("./*[local-name()='dataAktualizacji']").text,
                  initialized_from_esod:              true, 
                  netpar_user:                        nil  
                  )
                @matter.esod_matter_notes.create(
                  sprawa:         row.xpath("./*[local-name()='nrid']").text,   
                  tytul:          row.xpath("./*[local-name()='adnotacja']").xpath("./*[local-name()='tytul']").text.strip   
                  ) if row.xpath("./*[local-name()='adnotacja']").text.present?
              end

              self.get_wyszukaj_dokumenty_sprawy(@matter)
            end
            
          end
        end
      end
    end


  end



  def self.get_wyszukaj_dokumenty_sprawy(matter)
    my_token = Esodes::EsodTokenData.token_string

    if Esodes::EsodTokenData.response_token_errors.present? 
      Esodes::EsodTokenData.response_token_errors.each do |err|
        puts "#{err}"
      end
      return false
    end

    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Rails.application.secrets[:wso2ei_url]}/services/SprawaESODUsluga?wsdl",
      endpoint: "#{Rails.application.secrets[:wso2ei_url]}/services/SprawaESODUsluga.SprawaESODUslugaHttpsSoap11Endpoint",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:spr" => "http://sprawaESOD.uslugi.epl.uke.gov.pl/"
                  },
      namespace_identifier: :spr, 
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
      soap_version: 1,
      wsse_timestamp: true,
      ssl_verify_mode: :none,
      headers: { "Authorization" => "Basic #{Esodes::base64_user_and_pass}" },
      wsse_auth: [Esodes::EsodTokenData.netpar_user.email, my_token],
      soap_header: { "spr:metaParametry" => 
                      { "spr:identyfikatorStanowiska" => Esodes::EsodTokenData.token_stanowiska.first[:nrid] } 
                    }
    )

    message_body = { 
      "parametryOperacjiPobierzDokumentySprawy" => {
        "nrid" => "#{matter.nrid}"
      }
    }

    response = client.call(:pobierz_dokumenty_sprawy,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='pobierzDokumentySprawyResponse']").each do |resp|
        resp.xpath("./*[local-name()='return']").each do |ret|

          ret.xpath("./*[local-name()='dokumentySpraw'][@xsi:type='ns1:dokumentPrzychodzacy']").each do |row|
            row.xpath("./*[local-name()='kontrahent']").each do |nad|

              @contractor = Esod::Contractor.find_by(nrid: nad.xpath("./*[local-name()='nrid']").text)
              if @contractor.present?
                @contractor.imie                              = nad.xpath("./*[local-name()='imie']").text
                @contractor.nazwisko                          = nad.xpath("./*[local-name()='nazwisko']").text
                @contractor.pesel                             = nad.xpath("./*[local-name()='pesel']").text
                @contractor.rodzaj                            = nad.xpath("./*[local-name()='rodzaj']").xpath("./*[local-name()='nrid']").text
                @contractor.save! if @contractor.changed?
              else
                @contractor = Esod::Contractor.create(
                  nrid:                               nad.xpath("./*[local-name()='nrid']").text,  
                  imie:                               nad.xpath("./*[local-name()='imie']").text,
                  nazwisko:                           nad.xpath("./*[local-name()='nazwisko']").text,
                  pesel:                              nad.xpath("./*[local-name()='pesel']").text,
                  rodzaj:                             nad.xpath("./*[local-name()='rodzaj']").xpath("./*[local-name()='nrid']").text,
                  initialized_from_esod:              true, 
                  netpar_user:                        nil  
                  )
              end

              @address = Esod::Address.find_by(nrid: nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='nrid']").text)
              if @address.present?
                @address.data_utworzenia                   = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='dataUtworzenia']").text
                @address.identyfikator_osoby_tworzacej     = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='identyfikatorOsobyTworzacej']").text
                @address.data_modyfikacji                  = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='dataModyfikacji']").text
                @address.identyfikator_osoby_modyfikujacej = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='identyfikatorOsobyModyfikujacej']").text
                @address.nrid                              = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='nrid']").text  
                @address.miasto                            = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='miasto']").text
                @address.miasto_poczty                     = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='miastoPoczty']").text
                @address.kod_pocztowy                      = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='kodPocztowy']").text
                @address.ulica                             = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='ulica']").text
                @address.numer_budynku                     = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='numerBudynku']").text
                @address.numer_lokalu                      = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='numerLokalu']").text
                @address.panstwo                           = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='panstwo']").text
                @address.typ                               = nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='typ']").text
                @address.save! if @address.changed?
              else
                @address = Esod::Address.create(
                  data_utworzenia:                    nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='dataUtworzenia']").text,
                  identyfikator_osoby_tworzacej:      nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='identyfikatorOsobyTworzacej']").text,
                  data_modyfikacji:                   nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='dataModyfikacji']").text,
                  identyfikator_osoby_modyfikujacej:  nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='identyfikatorOsobyModyfikujacej']").text,
                  nrid:                               nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='nrid']").text,  
                  miasto:                             nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='miasto']").text,
                  miasto_poczty:                      nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='miastoPoczty']").text,
                  kod_pocztowy:                       nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='kodPocztowy']").text,
                  ulica:                              nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='ulica']").text,
                  numer_budynku:                      nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='numerBudynku']").text,
                  numer_lokalu:                       nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='numerLokalu']").text,
                  panstwo:                            nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='panstwo']").text,
                  typ:                                nad.xpath("./*[local-name()='adres']").xpath("./*[local-name()='typ']").text,
                  initialized_from_esod:              true, 
                  netpar_user:                        nil  
                  )
              end

            end

            inc_letter = Esod::IncomingLetter.find_by(nrid: row.xpath("./*[local-name()='nrid']").text)
            if inc_letter.present?
              inc_letter.data_nadania                         = row.xpath("./*[local-name()='dataNadania']").text 
              inc_letter.data_pisma                           = row.xpath("./*[local-name()='dataPisma']").text
              inc_letter.data_wplyniecia                      = row.xpath("./*[local-name()='dataWplyniecia']").text 
              inc_letter.identyfikator_rodzaju_dokumentu      = row.xpath("./*[local-name()='identyfikatorRodzajuDokumentu']").text 
              inc_letter.identyfikator_sposobu_przeslania     = row.xpath("./*[local-name()='identyfikatorSposobuPrzeslania']").text 
              inc_letter.identyfikator_typu_dcmd              = row.xpath("./*[local-name()='identyfikatorTypuDCMD']").text 
              inc_letter.naturalny_elektroniczny              = row.xpath("./*[local-name()='naturalnyElektroniczny']").text
              inc_letter.numer_ewidencyjny                    = row.xpath("./*[local-name()='numerEwidencyjny']").text
              inc_letter.pelna_wersja_cyfrowa                 = row.xpath("./*[local-name()='pelnaWersjaCyfrowa']").text
              inc_letter.uwagi                                = row.xpath("./*[local-name()='uwagi']").text
              inc_letter.znak_pisma_wplywajacego              = row.xpath("./*[local-name()='znakPismaWplywajacego']").text 
              inc_letter.tytul                                = row.xpath("./*[local-name()='opis']").text 
              inc_letter.termin_na_odpowiedz                  = row.xpath("./*[local-name()='terminNaOdpowiedz']").text
              inc_letter.liczba_zalacznikow                   = row.xpath("./*[local-name()='liczbaZalacznikow']").text
              # tutaj tajemnica i zgoda
              inc_letter.identyfikator_osoby                  = @contractor.nrid
              inc_letter.identyfikator_adresu                 = @address.nrid
              inc_letter.esod_contractor_id                   = @contractor.id 
              inc_letter.esod_address_id                      = @address.id
              inc_letter.save! if inc_letter.changed?
            else
              esod_incoming_letter = Esod::IncomingLetter.create(
                data_nadania:                         row.xpath("./*[local-name()='dataNadania']").text, 
                data_pisma:                           row.xpath("./*[local-name()='dataPisma']").text,
                data_wplyniecia:                      row.xpath("./*[local-name()='dataWplyniecia']").text, 
                identyfikator_rodzaju_dokumentu:      row.xpath("./*[local-name()='identyfikatorRodzajuDokumentu']").text, 
                identyfikator_sposobu_przeslania:     row.xpath("./*[local-name()='identyfikatorSposobuPrzeslania']").text, 
                identyfikator_typu_dcmd:              row.xpath("./*[local-name()='identyfikatorTypuDCMD']").text, 
                naturalny_elektroniczny:              row.xpath("./*[local-name()='naturalnyElektroniczny']").text,
                nrid:                                 row.xpath("./*[local-name()='nrid']").text,  
                numer_ewidencyjny:                    row.xpath("./*[local-name()='numerEwidencyjny']").text,
                pelna_wersja_cyfrowa:                 row.xpath("./*[local-name()='pelnaWersjaCyfrowa']").text,
                uwagi:                                row.xpath("./*[local-name()='uwagi']").text,
                znak_pisma_wplywajacego:              row.xpath("./*[local-name()='znakPismaWplywajacego']").text, 
                tytul:                                row.xpath("./*[local-name()='opis']").text, 
                termin_na_odpowiedz:                  row.xpath("./*[local-name()='terminNaOdpowiedz']").text,
                liczba_zalacznikow:                   row.xpath("./*[local-name()='liczbaZalacznikow']").text,
                identyfikator_osoby:                  @contractor.nrid,
                identyfikator_adresu:                 @address.nrid,
                esod_contractor_id:                   @contractor.id, 
                esod_address_id:                      @address.id,
                initialized_from_esod:                true, 
                netpar_user:                          nil  
                )

              esod_incoming_letter.esod_incoming_letters_matters.create(
                esod_matter_id:                       matter.id,
                sprawa:                               matter.nrid,   
                dokument:                             row.xpath("./*[local-name()='nrid']").text,   
                sygnatura:                            row.xpath("./*[local-name()='sygnatura']").text,  
                initialized_from_esod:                true,
                netpar_user:                          nil )
            end
          end

          ret.xpath("./*[local-name()='dokumentySpraw'][@xsi:type='ns1:dokumentWychodzacy']").each do |row|
            out_letter = Esod::OutgoingLetter.find_by(nrid: row.xpath("./*[local-name()='nrid']").text)
            if out_letter.present?
              out_letter.data_pisma                            = row.xpath("./*[local-name()='dataPisma']").text 
              out_letter.identyfikator_rodzaju_dokumentu_wychodzacego = row.xpath("./*[local-name()='identyfkatorRodzajuDokumentuWychodzacego']").text 
              out_letter.nrid                                  = row.xpath("./*[local-name()='nrid']").text
              out_letter.numer_ewidencyjny                     = row.xpath("./*[local-name()='numerEwidencyjny']").text
              out_letter.numer_wersji                          = row.xpath("./*[local-name()='numerWersji']").text 
              out_letter.tytul                                 = row.xpath("./*[local-name()='opis']").text
              out_letter.identyfikator_adresu                  = row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='identyfikatorAdresu']").text
              out_letter.identyfikator_sposobu_wysylki         = row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='identyfikatorSposobuWysylki']").text
              out_letter.data_wyslania                         = row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='dataWyslania']").text
              out_letter.czy_adresat_glowny                    = row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='czyAdresatGlowny']").text
              out_letter.save! if out_letter.changed?
            else
              esod_outgoing_letter = Esod::OutgoingLetter.create(
                nrid:                                 row.xpath("./*[local-name()='nrid']").text,
                numer_ewidencyjny:                    row.xpath("./*[local-name()='numerEwidencyjny']").text,
                tytul:                                row.xpath("./*[local-name()='opis']").text,
                identyfikator_adresu:                 row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='identyfikatorAdresu']").text,
                identyfikator_sposobu_wysylki:        row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='identyfikatorSposobuWysylki']").text,
                data_wyslania:                        row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='dataWyslania']").text,
                czy_adresat_glowny:                   row.xpath("./*[local-name()='wysylka']").xpath("./*[local-name()='czyAdresatGlowny']").text,
                identyfikator_rodzaju_dokumentu_wychodzacego: row.xpath("./*[local-name()='identyfkatorRodzajuDokumentuWychodzacego']").text, 
                data_pisma:                           row.xpath("./*[local-name()='dataPisma']").text, 
                numer_wersji:                         row.xpath("./*[local-name()='numerWersji']").text, 
                initialized_from_esod:                true, 
                netpar_user:                          nil  
                )

              esod_outgoing_letter.esod_outgoing_letters_matters.create(
                esod_matter_id:                       matter.id,
                sprawa:                               matter.nrid,   
                dokument:                             row.xpath("./*[local-name()='nrid']").text,   
                sygnatura:                            row.xpath("./*[local-name()='sygnatura']").text,  
                initialized_from_esod:                true,
                netpar_user:                          nil )

            end
          end

          ret.xpath("./*[local-name()='dokumentySpraw'][@xsi:type='ns1:dokumentWewnetrzny']").each do |row|
            int_letter = Esod::InternalLetter.find_by(nrid: row.xpath("./*[local-name()='nrid']").text)
            if int_letter.present?
              int_letter.numer_ewidencyjny                     = row.xpath("./*[local-name()='numerEwidencyjny']").text
              int_letter.tytul                                 = row.xpath("./*[local-name()='opis']").text
              int_letter.uwagi                                 = row.xpath("./*[local-name()='uwagi']").text
              int_letter.identyfikator_rodzaju_dokumentu_wewnetrznego = row.xpath("./*[local-name()='identyfikatorRodzajuDokumentuWewnetrznego']").text
              int_letter.identyfikator_typu_dcmd               = row.xpath("./*[local-name()='identyfikatorTypuDCMD']").text
              int_letter.identyfikator_dostepnosci_dokumentu   = row.xpath("./*[local-name()='identyfikatorDostepnosciDokumentu']").text
              int_letter.pelna_wersja_cyfrowa                  = row.xpath("./*[local-name()='czyPelnaWersjaCyfrowa']").text
              int_letter.save! if int_letter.changed?
            else
              esod_internal_letter = Esod::InternalLetter.create(
                nrid:                                 row.xpath("./*[local-name()='nrid']").text,
                numer_ewidencyjny:                    row.xpath("./*[local-name()='numerEwidencyjny']").text,
                tytul:                                row.xpath("./*[local-name()='opis']").text,
                uwagi:                                row.xpath("./*[local-name()='uwagi']").text,
                identyfikator_rodzaju_dokumentu_wewnetrznego: row.xpath("./*[local-name()='identyfikatorRodzajuDokumentuWewnetrznego']").text,
                identyfikator_typu_dcmd:              row.xpath("./*[local-name()='identyfikatorTypuDCMD']").text,
                identyfikator_dostepnosci_dokumentu:  row.xpath("./*[local-name()='identyfikatorDostepnosciDokumentu']").text,
                pelna_wersja_cyfrowa:                 row.xpath("./*[local-name()='czyPelnaWersjaCyfrowa']").text,
                initialized_from_esod:                true,
                netpar_user:                          nil )

              esod_internal_letter.esod_internal_letters_matters.create(
                esod_matter_id:                       matter.id,
                sprawa:                               matter.nrid,   
                dokument:                             row.xpath("./*[local-name()='nrid']").text,   
                sygnatura:                            row.xpath("./*[local-name()='sygnatura']").text,  
                initialized_from_esod:                true,
                netpar_user:                          nil )
            end
          end

        end
      end
    end

    #rescue 
    #  logger.fatal "ERROR!!! "

  end


end