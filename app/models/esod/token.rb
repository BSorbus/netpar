require 'esodes'

class Esod::Token
  attr_reader :token_string, :response_data, :response_errors

  include ApplicationHelper

  def initialize(esod_email, esod_pass)
    client = Savon.client(
      encoding: "UTF-8",

      wsdl: "#{Esodes::API_SERVER}/services/BezpieczenstwoESODUsluga?wsdl",
      endpoint: "#{Esodes::API_SERVER}/services/BezpieczenstwoESODUsluga.BezpieczenstwoESODUslugaHttpsSoap11Endpoint",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:tec" => "http://bezpieczenstwoESOD.uslugi.epl.uke.gov.pl/" },
      env_namespace: :soapenv,
      namespace_identifier: :tec,  
#      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      soap_version: 1,
#      wsse_timestamp: true,
      ssl_verify_mode: :none,
      headers: { "Authorization" => "Basic #{Esodes::base64_user_and_pass}" }
    )

    @response_errors ||= []

    message_body = { 
      "parametrWystawTokenESOD" => {
        "identyfikatorUzytkownika" => "#{esod_email}",
        "skrotHasla" => "#{esod_pass}"
        }
      }

    response = client.call( :wystaw_token_esod, message: message_body )
#    response = client.call(:wystaw_token, message: { "identyfikatorUzytkownika" => "#{esod_email}", "skrotHasla" => "#{esod_pass}" } )

    if response.success?
      @token_string = response.to_hash[:wystaw_token_esod_response][:return][:token]
      @response_data = response
      #@response_data_xml = response.to_xml.force_encoding('UTF-8')
      #@response_data_hash = response.to_hash
    end


    rescue Savon::HTTPError => error
      Rails.logger.fatal '==================================================================='
      Rails.logger.fatal '                      ----- token.rb  -----'                       
      Rails.logger.fatal '         ----- Savon::HTTPError => error  -----'
      Rails.logger.fatal "#{error.inspect}"
      Rails.logger.fatal "error.http.code: #{error.http.code}, faultcode: #{error.to_hash[:fault][:faultcode]}, faultstring: #{error.to_hash[:fault][:faultstring]}, detail: #{error.to_hash[:fault][:detail]}"
      Rails.logger.fatal '==================================================================='
      @response_errors << "Savon::HTTPError => #{error.inspect}, error.http.code: #{error.http.code}, faultcode: #{error.to_hash[:fault][:faultcode]}, faultstring: #{error.to_hash[:fault][:faultstring]}, detail: #{error.to_hash[:fault][:detail]}"
      false

    rescue Savon::SOAPFault => error
      Rails.logger.fatal '==================================================================='
      Rails.logger.fatal '                      ----- token.rb  -----'                       
      Rails.logger.fatal '         ----- Savon::SOAPFault => error  -----'
      Rails.logger.fatal "#{error.inspect}"
      Rails.logger.fatal "error.http.code: #{error.http.code}, faultcode: #{error.to_hash[:fault][:faultcode]}, faultstring: #{error.to_hash[:fault][:faultstring]}, detail: #{error.to_hash[:fault][:detail]}"
      Rails.logger.fatal '==================================================================='
      @response_errors << "Savon::SOAPFault => #{error.inspect}, error.http.code: #{error.http.code}, faultcode: #{error.to_hash[:fault][:faultcode]}, faultstring: #{error.to_hash[:fault][:faultstring]}, detail: #{error.to_hash[:fault][:detail]}"
      false

    rescue Savon::InvalidResponseError => error
      Rails.logger.fatal '==================================================================='
      Rails.logger.fatal '                      ----- token.rb  -----'                       
      Rails.logger.fatal '         ----- Savon::InvalidResponseError => error  -----'
      Rails.logger.fatal "#{error.inspect}"
      Rails.logger.fatal "error.http.code: #{error.http.code}, faultcode: #{error.to_hash[:fault][:faultcode]}, faultstring: #{error.to_hash[:fault][:faultstring]}, detail: #{error.to_hash[:fault][:detail]}"
      Rails.logger.fatal '==================================================================='
      @response_errors << "Savon::InvalidResponseError => #{error.inspect}, error.http.code: #{error.http.code}, faultcode: #{error.to_hash[:fault][:faultcode]}, faultstring: #{error.to_hash[:fault][:faultstring]}, detail: #{error.to_hash[:fault][:detail]}"
      false

    rescue Savon::Error => error
      Rails.logger.fatal '==================================================================='
      Rails.logger.fatal '                      ----- token.rb  -----'                       
      Rails.logger.fatal '               ----- Savon::Error => error  -----'
      Rails.logger.fatal "#{error.inspect}"
      Rails.logger.fatal "error.http.code: #{error.http.code}, faultcode: #{error.to_hash[:fault][:faultcode]}, faultstring: #{error.to_hash[:fault][:faultstring]}, detail: #{error.to_hash[:fault][:detail]}"
      Rails.logger.fatal '==================================================================='
      @response_errors << "Savon::Error => #{error.inspect}, error.http.code: #{error.http.code}, faultcode: #{error.to_hash[:fault][:faultcode]}, faultstring: #{error.to_hash[:fault][:faultstring]}, detail: #{error.to_hash[:fault][:detail]}"
      false

    rescue SocketError => error
      Rails.logger.fatal '==================================================================='
      Rails.logger.fatal '                      ----- token.rb  -----'                       
      Rails.logger.fatal '                ----- SocketError => error  -----'
      Rails.logger.fatal "#{error.inspect}"
      Rails.logger.fatal '==================================================================='
      @response_errors << "SocketError => #{error.inspect}"
      false

    rescue => error
      Rails.logger.fatal '==================================================================='
      Rails.logger.fatal '                      ----- token.rb  -----'                       
      Rails.logger.fatal '                      ----- => error  -----'
      Rails.logger.fatal "#{error.inspect}"
      Rails.logger.fatal '==================================================================='
      @response_errors << "error => #{error.inspect}"
      false
  end

  def stanowiska
    my_array = []
    self.response_data.xpath("//*[local-name()='stanowisko']").each do |row|
      my_array << {
                    nrid:                                   row.xpath("./*[local-name()='nrid']").text,
                    nazwa:                                  row.xpath("./*[local-name()='nazwa']").text,
                    identyfikator_komorki_organizacyjnej:   row.xpath("./*[local-name()='identyfikatorKomorkiOrganizacyjnej']").text,
                    imie:                                   row.xpath("./*[local-name()='imie']").text,
                    nazwisko:                               row.xpath("./*[local-name()='nazwisko']").text,
                    aktywne_zastepstwo:                     row.xpath("./*[local-name()='aktywneZastepstwo']").text,
                    identyfikator_kancelarii_przychodzacej: row.xpath("./*[local-name()='identyfikatorKancelariiPrzychodzacej']").text,
                    identyfikator_kancelarii_wychodzacej:   row.xpath("./*[local-name()='identyfikatorKancelariiWychodzacej']").text,
                  }
    end    
    
    return my_array
  end

end
