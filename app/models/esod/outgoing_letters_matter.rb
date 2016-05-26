class Esod::OutgoingLettersMatter < ActiveRecord::Base
  belongs_to :esod_outgoing_letter, class_name: "Esod::OutgoingLetter", foreign_key: :esod_outgoing_letter_id
  belongs_to :esod_matter, class_name: "Esod::Matter", foreign_key: :esod_matter_id

  # callbacks
  #before_save :insert_data_to_esod_and_update_self, on: :create, if: "initialized_from_esod == false"
  before_save :push_data_to_esod_and_update_self, on: :create, if: "initialized_from_esod == false"

  def push_data_to_esod_and_update_self
    #self.esod_incoming_letter.insert_data_to_esod_and_update_self
    self.insert_data_to_esod_and_update_self
  end

  def insert_data_to_esod_and_update_self
    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Esodes::ESOD_API_SERVER}/wsdl/dokumenty/ws/dokumenty_wychodzace.wsdl",
      endpoint: "#{Esodes::ESOD_API_SERVER}/uslugi.php/dokumentywychodzace/handle",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:dok" => "http://www.dokus.pl/dokumenty/ws/dokumentywychodzace", 
                    "xmlns:dok1" => "http://www.dokus.pl/dokumenty/mt/dokumenty_wychodzace", 
                    "xmlns:mt" => "http://www.dokus.pl/dokumenty/pliki/mt", 
                    "xmlns:slow" => "http://www.dokus.pl/slowniki/mt/slowniki", 
                    "xmlns:wsp" => "http://www.dokus.pl/wspolne",
                    "xmlns:ns1" => "http://www.dokus.pl/wspolne", 
                    "xmlns:ns2" => "http://www.dokus.pl/dokumenty/mt/dokumenty_wychodzace", 
                    "xmlns:ns3" => "http://www.dokus.pl/dokumenty/pliki/mt", 
                    "xmlns:ns4" => "http://www.dokus.pl/dokumenty/ws/dokumentywychodzace"
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
      "dok1:identyfikatorSprawy" => "#{self.sprawa}", 
      "dok1:tytul" => "#{self.esod_outgoing_letter.tytul}", 
      "dok1:tresc" => "#{self.esod_outgoing_letter.uwagi}", 
      "dok1:wysylka" => {
        "identyfikatorAdresu" => "#{self.esod_outgoing_letter.identyfikator_adresu}",
        "identyfikatorSposobuWysylki" => "#{self.esod_outgoing_letter.identyfikator_sposobu_wysylki}",
        "dataWyslania" => "#{self.esod_outgoing_letter.data_wyslania}",
        "czyAdresatGlowny" => true
      },
      "dok1:identyfkatorRodzajuDokumentuWychodzacego" => "#{self.esod_outgoing_letter.identyfikator_rodzaju_dokumentu_wychodzacego}",
      "dok1:dataPisma" => "#{self.esod_outgoing_letter.data_pisma}",
      "dok1:zakonczSprawe" => "#{self.esod_outgoing_letter.zakoncz_sprawe}",
      "dok1:zaakceptujDokument" => "#{self.esod_outgoing_letter.zaakceptuj_dokument}"
      }

    response = client.call(:utworz_dokument_wychodzacy,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='utworzDokumentWychodzacyResponse']").each do |row|
        self.esod_outgoing_letter.data_utworzenia = row.xpath("./*[local-name()='dataUtworzenia']").text
        self.esod_outgoing_letter.identyfikator_osoby_tworzacej = row.xpath("./*[local-name()='identyfikatorOsobyTworzacej']").text
        self.esod_outgoing_letter.data_modyfikacji = row.xpath("./*[local-name()='dataModyfikacji']").text
        self.esod_outgoing_letter.identyfikator_osoby_modyfikujacej = row.xpath("./*[local-name()='identyfikatorOsobyModyfikujacej']").text
        self.esod_outgoing_letter.numer_ewidencyjny = row.xpath("./*[local-name()='numerEwidencyjny']").text
        self.esod_outgoing_letter.wysylka = row.xpath("./*[local-name()='wysylka']").text
        self.esod_outgoing_letter.nrid = row.xpath("./*[local-name()='nrid']").text 
        self.esod_outgoing_letter.save
        self.sygnatura = row.xpath("./*[local-name()='sygnatura']").text
        self.dokument = self.esod_outgoing_letter.nrid
      end
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

      errors.add(:base, "HTTPError => e, e.message, faultcode...")
      false
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
