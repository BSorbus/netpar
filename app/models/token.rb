class Token
  attr_reader :token_string, :stanowiska, :stanowisko_first, :identyfikator_komorki_organizacyjnej_first


  def initialize(esod_email, esod_pass)
    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "http://testesod.uke.gov.pl/wsdl/wspolne/ws/uwierzytelnienie.wsdl",
      strip_namespaces: true,
      logger: Rails.logger,
    )

    response = client.call(:wystaw_token, message: { "identyfikatorUzytkownika" => esod_email, "skrotHasla" => esod_pass })

    if response.success?
      data = response.to_hash[:wystaw_token_response]
      if data
        @token_string = data[:token]
        @stanowiska = data[:stanowiska]
        @stanowisko_first = @stanowiska.first[1][:nrid]
        @identyfikator_komorki_organizacyjnej_first = @stanowiska.first[1][:identyfikator_komorki_organizacyjnej]
      end
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
