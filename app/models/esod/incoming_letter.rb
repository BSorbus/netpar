class Esod::IncomingLetter < ActiveRecord::Base
  has_many :esod_incoming_letters_matters, class_name: 'Esod::IncomingLettersMatter', foreign_key: :esod_incoming_letter_id 
  has_many :esod_matters, through: :esod_incoming_letters_matters

  belongs_to :esod_contractor, class_name: 'Esod::Contractor'
  belongs_to :esod_address, class_name: 'Esod::Address'

  has_many :works, as: :trackable, source_type: 'Esod::IncomingLetter'


  def fullname
    "#{self.esod_incoming_letters_matters.last.sygnatura}"
    # "#{znak}, [#{iks_name}] (#{id})"
  end
  def fullname_and_id
    "#{self.esod_incoming_letters_matters.last.sygnatura} (#{id})"
    # "#{znak}, [#{iks_name}] (#{id})"
  end


  def push_soap_and_save(matter)
    my_token = Esodes::EsodTokenData.token_string
    if Esodes::EsodTokenData.response_token_errors.present? 
      errors.add(:base, "Błąd! #{Esodes::EsodTokenData.response_token_errors}")
      return false
    end

    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Esodes::API_SERVER}/services/DokumentPrzychodzacyESODUsluga?wsdl",
      endpoint: "#{Esodes::API_SERVER}/services/DokumentPrzychodzacyESODUsluga.DokumentPrzychodzacyESODUslugaHttpsSoap11Endpoint",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:dok" => "http://dokumentprzychodzacy.dokument.uslugi.epl.uke.gov.pl/" 
                  },
      env_namespace: :soapenv,
      namespace_identifier: :dok, 
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
      soap_header: { "dok:metaParametry" => 
                      { "dok:identyfikatorStanowiska" => Esodes::EsodTokenData.token_stanowiska.first[:nrid] } 
                    }
    )

    message_body = { 
      "parametryOperacjiUtworzDokumentPrzychodzacy" => {
        "dataNadania" => "#{self.data_nadania}",
        "dataPisma" => "#{self.data_pisma}",
        "dataWplyniecia" => "#{self.data_wplyniecia}",
        "identyfikatorRodzajuDokumentu" => "#{self.identyfikator_rodzaju_dokumentu}",
        "identyfikatorSposobuPrzeslania" => "#{self.identyfikator_sposobu_przeslania}",
        "identyfikatorTypuDCMD" => "#{self.identyfikator_typu_dcmd}",
        "naturalnyElektroniczny" => "#{self.naturalny_elektroniczny}",
        "opis" => "#{self.tytul}", 
        "pelnaWersjaCyfrowa" => "#{self.pelna_wersja_cyfrowa}",
        "terminNaOdpowiedz" => "#{self.termin_na_odpowiedz}",
        "uwagi" => "#{self.uwagi}",
        "znakPismaWplywajacego" => "#{self.znak_pisma_wplywajacego}",
        "identyfikatorAdresu" => "#{self.identyfikator_adresu}",
        "liczbaZalacznikow" => "#{self.liczba_zalacznikow}"
      }
    }
  


    response = client.call(:utworz_dokument_przychodzacy,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='return']").each do |ret|
        response.xpath("//*[local-name()='dokumentPrzychodzacy']").each do |row|
          self.numer_ewidencyjny = row.xpath("./*[local-name()='numerEwidencyjny']").text
          self.nrid = row.xpath("./*[local-name()='nrid']").text 
          self.save

          #połącz pismo ze sprawą
          esod_ilm = self.esod_incoming_letters_matters.new(
            esod_matter_id: matter.id,  
            sprawa: matter.nrid,   
            dokument: self.nrid,   
            sygnatura: nil,
            initialized_from_esod: false,
            netpar_user: self.netpar_user)
          if esod_ilm.push_soap_and_save
            true
          else
            esod_ilm.errors.full_messages.each do |msg|
              self.errors.add(:base, "#{msg}")
            end
            false
          end
        end
      end # /response.xpath("//*[local-name()='return']").each do |ret|
    else
      false
    end # /response.success?

    rescue Savon::HTTPError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_przychodzacy", 
                              base_obj:   self )
      false

    rescue Savon::SOAPFault => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_przychodzacy", 
                              base_obj:   self )
      false

    rescue Savon::InvalidResponseError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_przychodzacy", 
                              base_obj:   self )
      false

    rescue Savon::Error => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_przychodzacy", 
                              base_obj:   self )
      false

    rescue SocketError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_przychodzacy", 
                              base_obj:   self )
      false

    rescue => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_przychodzacy", 
                              base_obj:   self )
      false

  end


end

