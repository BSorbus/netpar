class Esod::InternalLetter < ActiveRecord::Base
  has_many :esod_internal_letters_matters, class_name: 'Esod::InternalLettersMatter', foreign_key: :esod_internal_letter_id 
  has_many :esod_matters, through: :esod_internal_letters_matters

  has_many :works, as: :trackable, source_type: 'Esod::InternalLetter'

  def fullname
    "#{self.esod_internal_letters_matters.last.sygnatura}"
    # "#{znak}, [#{iks_name}] (#{id})"
  end

  def fullname_and_id
    "#{self.esod_internal_letters_matters.last.sygnatura} (#{id})"
    # "#{znak}, [#{iks_name}] (#{id})"
  end


  def push_soap_and_save(matter)
    my_token = Esodes::EsodTokenData.token_string
    if Esodes::EsodTokenData.response_token_errors.present? 
      Esodes::EsodTokenData.response_token_errors.each do |err|
        errors.add(:base, "#{err}")
      end
      return false
    end

    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Esodes::API_SERVER}/services/DokumentWewnetrznyESODUsluga?wsdl",
      endpoint: "#{Esodes::API_SERVER}/services/DokumentWewnetrznyESODUsluga.DokumentWewnetrznyESODUslugaHttpsSoap11Endpoint",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:dok" => "http://dokumentwewnetrznyESOD.dokument.uslugi.epl.uke.gov.pl/" 
                  },
      namespace_identifier: :dok,  
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug, # [:debug, :info, :warn, :error, :fatal]
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
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
      "parametryOperacjiUtworzDokumentWewnetrzny" => {
        "opis" => "#{self.tytul}", 
        "uwagi" => "#{self.uwagi}", 
        "identyfikatorRodzajuDokumentuWewnetrznego" => "#{self.identyfikator_rodzaju_dokumentu_wewnetrznego}",
        "identyfikatorTypuDCMD" => "#{self.identyfikator_typu_dcmd}",
        "identyfikatorDostepnosciDokumentu" => "#{self.identyfikator_dostepnosci_dokumentu}",
        "pelnaWersjaCyfrowa" => "#{self.pelna_wersja_cyfrowa}",
        "identyfikatorSprawy" => "#{matter.nrid}"
      }
    }

    response = client.call(:utworz_dokument_wewnetrzny,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='return']").each do |ret|
        response.xpath("//*[local-name()='dokumentWewnetrzny']").each do |row|
          self.numer_ewidencyjny = row.xpath("./*[local-name()='numerEwidencyjny']").text
          self.nrid = row.xpath("./*[local-name()='nrid']").text 
          self.save

          self.esod_internal_letters_matters.create(
            esod_matter_id: matter.id,  
            sprawa: matter.nrid,   
            dokument: self.nrid,   
            sygnatura: row.xpath("./*[local-name()='sygnatura']").text,
            initialized_from_esod: false,
            netpar_user: self.netpar_user)

          true
        end
      end
    else
      false
    end


    rescue Savon::HTTPError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\internal_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_wewnetrzny", 
                              base_obj:   self )

      false


    rescue Savon::SOAPFault => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\internal_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_wewnetrzny", 
                              base_obj:   self )

      false

    rescue Savon::InvalidResponseError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\internal_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_wewnetrzny", 
                              base_obj:   self )

      false


    rescue Savon::Error => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\internal_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_wewnetrzny", 
                              base_obj:   self )

      false

    rescue SocketError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\internal_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_wewnetrzny", 
                              base_obj:   self )

      false

    rescue => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\internal_letter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "utworz_dokument_wewnetrzny", 
                              base_obj:   self )

      false
  end


end

