class Esod::Token
  attr_reader :token_string, :response_data, :response_http_error, :response_soap_error


  def initialize(esod_email, esod_pass)
    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "http://testesod.uke.gov.pl/wsdl/wspolne/ws/uwierzytelnienie.wsdl",
      endpoint: "http://testesod.uke.gov.pl/uslugi.php/uwierzytelnienie/handle",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:uwi" => "http://www.dokus.pl/wspolne/ws/uwierzytelnienie",
                    "xmlns:ns1" => "http://www.dokus.pl/slowniki/mt/slowniki", 
                    "xmlns:ns2" => "http://www.dokus.pl/wspolne/ws/uwierzytelnienie" },
      strip_namespaces: true,
      logger: Rails.logger,
      log_level: :debug,
      log: true,
      pretty_print_xml: true,
      env_namespace: :soapenv,
      soap_version: 2
    )


    response = client.call(
      :wystaw_token, message: { 
        "identyfikatorUzytkownika" => esod_email, 
        "skrotHasla" => esod_pass }
        )

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

  def default_one
    self.response_data.xpath("//stanowiska").first.xpath("//ns1:nrid").text
  end

  def default_first
    self.response_data.to_hash[:wystaw_token_response][:stanowiska].first[1][:nrid]
  end

  def stanowiska
    my_array = []
    self.response_data.xpath('//ns1:stanowisko').each do |row_element|

      my_array << {
                    nrid: row_element.at("//ns1:nrid").text,
                    nazwa: row_element.at("//ns1:nazwa").text,
                    identyfikator_komorki_organizacyjnej: row_element.at("//ns1:identyfikatorKomorkiOrganizacyjnej").text,
                    imie: row_element.at("//ns1:imie").text,
                    nazwisko: row_element.at("//ns1:nazwisko").text,
                    aktywne_zastepstwo: row_element.at("//ns1:aktywneZastepstwo").text,
                    identyfikator_kancelarii_przychodzacej: row_element.at("//ns1:identyfikatorKancelariiPrzychodzacej").text,
                    identyfikator_kancelarii_wychodzacej: row_element.at("//ns1:identyfikatorKancelariiWychodzacej").text
                  }
ssss
    end
    ss
    return my_array
  end

end
