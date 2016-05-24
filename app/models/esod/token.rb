require 'esodes'

class Esod::Token
  attr_reader :token_string, :response_data, :response_error_http_code, :response_error_faultcode, :response_error_faultstring, :response_error_faultdetail

  def initialize(esod_email, esod_pass)
    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Esodes::ESOD_API_SERVER}/wsdl/wspolne/ws/uwierzytelnienie.wsdl",
      endpoint: "#{Esodes::ESOD_API_SERVER}/uslugi.php/uwierzytelnienie/handle",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:ns1" => "http://www.dokus.pl/wspolne", 
                    "xmlns:ns2" => "http://www.dokus.pl/slowniki/mt/slowniki", 
                    "xmlns:ns3" => "http://www.dokus.pl/wspolne/ws/uwierzytelnienie" },
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
      soap_version: 2
    )

    response = client.call(:wystaw_token, message: { "identyfikatorUzytkownika" => "#{esod_email}", "skrotHasla" => "#{esod_pass}" } )

    if response.success?
      @token_string = response.to_hash[:wystaw_token_response][:token]
      #@stanowiska = response.to_hash[:wystaw_token_response][:stanowiska]
      #@stanowisko_first = @stanowiska.first[1][:nrid]
      @response_data = response
      #@response_data_xml = response.to_xml.force_encoding('UTF-8')
      #@response_data_hash = response.to_hash
      #response.xpath("//stanowiska").first.xpath("//ns1:imie").text
      #@identyfikator_komorki_organizacyjnej_first = @stanowiska.first[1][:identyfikator_komorki_organizacyjnej]
    end

    rescue Savon::HTTPError => error
      #Logger.log error.http.code
      @response_error_http_code = "#{error.http.code}"
      @response_error_faultcode = "#{error.to_hash[:fault][:faultcode]}"
      @response_error_faultstring = "#{error.to_hash[:fault][:faultstring]}"
      @response_error_faultdetail = "#{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      puts '      ----- Savon::HTTPError => error error.http.code -----'
      puts "error.http.code: #{error.http.code}"
      puts "      faultcode: #{error.to_hash[:fault][:faultcode]}"
      puts "    faultstring: #{error.to_hash[:fault][:faultstring]}"
      puts "         detail: #{error.to_hash[:fault][:detail]}"
      puts '==================================================================='

#logger.debug "Person attributes hash: #{@person.attributes.inspect}"
#logger.info "Processing the request..."
#logger.fatal "Terminating application, raised unrecoverable error!!!"

      raise error, "Savon::HTTPError => error, error.http.code: #{error.http.code}"
      false


    rescue Savon::SOAPFault => error
      #Logger.log error.http.code
      @response_error_http_code = "#{error.http.code}"
      @response_error_faultcode = "#{error.to_hash[:fault][:faultcode]}"
      @response_error_faultstring = "#{error.to_hash[:fault][:faultstring]}"
      @response_error_faultdetail = "#{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      puts '      ----- Savon::SOAPFault => error error.http.code -----'
      puts "error.http.code: #{error.http.code}"
      puts "      faultcode: #{error.to_hash[:fault][:faultcode]}"
      puts "    faultstring: #{error.to_hash[:fault][:faultstring]}"
      puts "         detail: #{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      #raise CustomError, fault_code
      raise error, "Savon::SOAPFault => error, error.http.code: #{error.http.code}"
      false

    rescue Savon::InvalidResponseError => error
      #Logger.log error.http.code
      @response_error_http_code = "#{error.http.code}"
      @response_error_faultcode = "#{error.to_hash[:fault][:faultcode]}"
      @response_error_faultstring = "#{error.to_hash[:fault][:faultstring]}"
      @response_error_faultdetail = "#{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      puts ' ----- Savon::InvalidResponseError => error error.http.code -----'
      puts "error.http.code: #{error.http.code}"
      puts "      faultcode: #{error.to_hash[:fault][:faultcode]}"
      puts "    faultstring: #{error.to_hash[:fault][:faultstring]}"
      puts "         detail: #{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      #raise CustomError, fault_code
      raise error, "Savon::InvalidResponseError => error, error.http.code: #{error.http.code}"
      false


    rescue Savon::Error => error
      #Logger.log error.http.code
      @response_error_http_code = "#{error.http.code}"
      @response_error_faultcode = "#{error.to_hash[:fault][:faultcode]}"
      @response_error_faultstring = "#{error.to_hash[:fault][:faultstring]}"
      @response_error_faultdetail = "#{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      puts '        ----- Savon::Error => error error.http.code -----'
      puts "error.http.code: #{error.http.code}"
      puts "      faultcode: #{error.to_hash[:fault][:faultcode]}"
      puts "    faultstring: #{error.to_hash[:fault][:faultstring]}"
      puts "         detail: #{error.to_hash[:fault][:detail]}"
      puts '==================================================================='
      raise error, "Savon::Error => error, error.http.code: #{error.http.code}"
      false
  end

  def default_one
    self.response_data.xpath("//stanowiska").first.xpath("//ns2:nrid").text
  end

  def default_first
    self.response_data.to_hash[:wystaw_token_response][:stanowiska].first[1][:nrid]
  end

  def stanowiska
    my_array = []
#    self.response_data.xpath('//ns2:stanowisko').each do |row|
#      my_array << {
#                    nrid:  row.xpath("./ns2:nrid").text,
#                    nazwa: row.xpath("./ns2:nazwa").text,
#                    identyfikator_komorki_organizacyjnej: row.xpath("//ns2:identyfikatorKomorkiOrganizacyjnej").text,
#                    imie: row.xpath("./ns2:imie").text,
#                    nazwisko: row.xpath("./ns2:nazwisko").text,
#                    aktywne_zastepstwo: row.xpath("./ns2:aktywneZastepstwo").text,
#                    identyfikator_kancelarii_przychodzacej: row.xpath("./ns2:identyfikatorKancelariiPrzychodzacej").text,
#                    identyfikator_kancelarii_wychodzacej: row.at("./ns2:identyfikatorKancelariiWychodzacej").text
#                  }

    self.response_data.xpath("//*[local-name()='stanowisko']").each do |row|
      my_array << {
                    nrid:  row.xpath("./*[local-name()='nrid']").text,
                    nazwa: row.xpath("./*[local-name()='nazwa']").text,
                    identyfikator_komorki_organizacyjnej: row.xpath("./*[local-name()='identyfikatorKomorkiOrganizacyjnej']").text,
                    imie: row.xpath("./*[local-name()='imie']").text,
                    nazwisko: row.xpath("./*[local-name()='nazwisko']").text,
                    aktywne_zastepstwo: row.xpath("./*[local-name()='aktywneZastepstwo']").text,
                    identyfikator_kancelarii_przychodzacej: row.xpath("./*[local-name()='identyfikatorKancelariiPrzychodzacej']").text,
                    identyfikator_kancelarii_wychodzacej: row.xpath("./*[local-name()='identyfikatorKancelariiWychodzacej']").text,
                  }
    end    
    
    return my_array
  end

end
