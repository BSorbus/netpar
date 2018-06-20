class Esod::IncomingLettersMatter < ActiveRecord::Base
  belongs_to :esod_incoming_letter, class_name: "Esod::IncomingLetter", foreign_key: :esod_incoming_letter_id
  belongs_to :esod_matter, class_name: "Esod::Matter", foreign_key: :esod_matter_id


  def push_soap_and_save
    my_token = Esodes::EsodTokenData.token_string
    if Esodes::EsodTokenData.response_token_errors.present? 
      Esodes::EsodTokenData.response_token_errors.each do |err|
        errors.add(:base, "#{err}")
      end
      return false
    end

    client = Savon.client(
      wsdl: "#{Esodes::API_SERVER}/services/SprawaESODUsluga?wsdl",
      endpoint: "#{Esodes::API_SERVER}/services/SprawaESODUsluga.SprawaESODUslugaHttpsSoap11Endpoint",
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
      "parametryOperacjiDodajDokumentPrzychodzacyDoSprawy" => {
        "identyfikatorDokumentu" => "#{self.dokument}",
        "identyfikatorSprawy" => "#{self.sprawa}"
        }
      }

    response = client.call(:dodaj_dokument_przychodzacy_do_sprawy,  message: message_body )

    if response.success?
      self.sygnatura = response.xpath("//*[local-name()='sygnatura']").text
      self.save
      true
    else
      false
    end

    rescue Savon::HTTPError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letters_matter.rb', 
                              function:  "push_soap_and_save", 
                              soap_function:  "dodaj_dokument_przychodzacy_do_sprawy", 
                              base_obj:   self )
      false

    rescue Savon::SOAPFault => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letters_matter.rb', 
                              function:  "push_soap_and_save(matter)", 
                              soap_function:  "dodaj_dokument_przychodzacy_do_sprawy", 
                              base_obj:   self )
      false

    rescue Savon::InvalidResponseError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letters_matter.rb', 
                              function:  "push_soap_and_save", 
                              soap_function:  "dodaj_dokument_przychodzacy_do_sprawy", 
                              base_obj:   self )
      false

    rescue Savon::Error => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letters_matter.rb', 
                              function:  "push_soap_and_save", 
                              soap_function:  "dodaj_dokument_przychodzacy_do_sprawy", 
                              base_obj:   self )
      false

    rescue SocketError => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letters_matter.rb', 
                              function:  "push_soap_and_save", 
                              soap_function:  "dodaj_dokument_przychodzacy_do_sprawy", 
                              base_obj:   self )
      false

    rescue => error
      Esodes::log_soap_error( error,
                              file:      '\models\esod\incoming_letters_matter.rb', 
                              function:  "push_soap_and_save", 
                              soap_function:  "dodaj_dokument_przychodzacy_do_sprawy", 
                              base_obj:   self )
      false

  end


end

