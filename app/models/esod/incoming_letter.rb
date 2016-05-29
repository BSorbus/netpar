class Esod::IncomingLetter < ActiveRecord::Base
  has_many :esod_incoming_letters_matters, class_name: 'Esod::IncomingLettersMatter', foreign_key: :esod_incoming_letter_id 
  has_many :esod_matters, through: :esod_incoming_letters_matters

  belongs_to :esod_contractor, class_name: 'Esod::Contractor'
  belongs_to :esod_address, class_name: 'Esod::Address'

  # callbacks
  # push data to ESOD after mamy_to_many (esod_incoming_letters_matters) created
  #before_save :insert_data_to_esod_and_update_self, on: :create, if: "initialized_from_esod == false"

  def insert_data_to_esod_and_update_self
    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Esodes::ESOD_API_SERVER}/wsdl/dokumenty/ws/dokumenty_przychodzace.wsdl",
      endpoint: "#{Esodes::ESOD_API_SERVER}/uslugi.php/dokumentyprzychodzace/handle",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:dok" => "http://www.dokus.pl/dokumenty/ws/dokumenty_przychodzace", 
                    "xmlns:dok1" => "http://www.dokus.pl/dokumenty/mt/dokumenty_przychodzace", 
                    "xmlns:mt" => "http://www.dokus.pl/dokumenty/pliki/mt", 
                    "xmlns:slow" => "http://www.dokus.pl/slowniki/mt/slowniki", 
                    "xmlns:wsp" => "http://www.dokus.pl/wspolne"
                  },
      namespace_identifier: :dok, #"xmlns:ws" => "http://www.dokus.pl/sprawy/ws/utworzSprawe", 
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
      "dok1:tytul" => "#{self.tytul}", 
      "dok1:dataPisma" => "#{self.data_pisma}",
      "dok1:dataNadania" => "#{self.data_nadania}",
      "dok1:dataWplyniecia" => "#{self.data_wplyniecia}",
      "dok1:znakPismaWplywajacego" => "#{self.znak_pisma_wplywajacego}",
      "dok1:idDCMD" => "#{self.identyfikator_typu_dcmd}",
      "dok1:idRodzaju" => "#{self.identyfikator_rodzaju_dokumentu}",
      "dok1:idSposobuPrzeslania" => "#{self.identyfikator_sposobu_przeslania}",
      "dok1:terminNaOdpowiedz" => "#{self.termin_na_odpowiedz}",
      "dok1:nadawca" => {
        "slow:identyfikatorOsoby" => "#{self.identyfikator_osoby}",
        "slow:identyfikatorAdresu" => "#{self.identyfikator_adresu}"
      },
      "dok1:pelnaWersjaCyfrowa" => "#{self.pelna_wersja_cyfrowa}",
      "dok1:naturalnyElektroniczny" => "#{self.naturalny_elektroniczny}"
    }

    response = client.call(:utworz_dokument_przychodzacy,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='utworzDokumentPrzychodzacyResponse']").each do |row|
        self.data_utworzenia = row.xpath("./*[local-name()='dataUtworzenia']").text
        self.identyfikator_osoby_tworzacej = row.xpath("./*[local-name()='identyfikatorOsobyTworzacej']").text
        self.data_modyfikacji = row.xpath("./*[local-name()='dataModyfikacji']").text
        self.identyfikator_osoby_modyfikujacej = row.xpath("./*[local-name()='identyfikatorOsobyModyfikujacej']").text
        self.numer_ewidencyjny = row.xpath("./*[local-name()='numerEwidencyjny']").text
        self.nrid = row.xpath("./*[local-name()='nrid']").text 
      end

      #self.data_utworzenia = response.xpath("//*[local-name()='dataUtworzenia']").text,
      #self.identyfikator_osoby_tworzacej = response.xpath("//*[local-name()='identyfikatorOsobyTworzacej']").text,
      #self.data_modyfikacji = response.xpath("//*[local-name()='dataModyfikacji']").text,
      #self.identyfikator_osoby_modyfikujacej = response.xpath("//*[local-name()='identyfikatorOsobyModyfikujacej']").text,
      #self.numer_ewidencyjny = response.xpath("//*[local-name()='numerEwidencyjny']").text
      #self.nrid = response.xpath("//*[local-name()='nrid']").text
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

