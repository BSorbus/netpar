require 'esodes'

class Esod::IncomingLettersMatter < ActiveRecord::Base
  belongs_to :esod_incoming_letter, class_name: "Esod::IncomingLetter", foreign_key: :esod_incoming_letter_id
  belongs_to :esod_matter, class_name: "Esod::Matter", foreign_key: :esod_matter_id


  # callbacks
  #before_save :insert_data_to_esod_and_update_self, on: :create, if: "initialized_from_esod == false"
  before_save :push_data_to_esod_and_update_self, on: :create, if: "initialized_from_esod == false"

  def push_data_to_esod_and_update_self
    self.esod_incoming_letter.insert_data_to_esod_and_update_self

    self.dokument = self.esod_incoming_letter.nrid 
    self.insert_data_to_esod_and_update_self
  end

  def insert_data_to_esod_and_update_self
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
      "mt:identyfikatorSprawy" => "#{self.sprawa}",
      "mt:identyfikatorDokumentu" => "#{self.dokument}"
      }

    response = client.call(:dodaj_dokument_przychodzacy_do_sprawy,  message: message_body )

    if response.success?
      self.sygnatura = response.xpath("//*[local-name()='sygnatura']").text
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


end

