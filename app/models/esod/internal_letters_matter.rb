class Esod::InternalLettersMatter < ActiveRecord::Base
  belongs_to :esod_internal_letter, class_name: "Esod::InternalLetter", foreign_key: :esod_internal_letter_id
  belongs_to :esod_matter, class_name: "Esod::Matter", foreign_key: :esod_matter_id

  # callbacks
  #before_save :insert_data_to_esod_and_update_self, on: :create, if: "initialized_from_esod == false"
  before_save :push_data_to_esod_and_update_self, on: :create, if: "initialized_from_esod == false"

  def push_data_to_esod_and_update_self
    #self.esod_incoming_letter.insert_data_to_esod_and_update_self
    self.insert_data_to_esod_and_update_self
  end

  def insert_data_to_esod_and_update_self

#logger.debug "Person attributes hash: #{@person.attributes.inspect}"
#logger.info "Processing the request..."
#logger.fatal "Terminating application, raised unrecoverable error!!!"

    client = Savon.client(
      encoding: "UTF-8",
      wsdl: "#{Esodes::ESOD_API_SERVER}/wsdl/dokumenty/ws/dokumenty_wewnetrzne.wsdl",
      endpoint: "#{Esodes::ESOD_API_SERVER}/uslugi.php/dokumentywewnetrzne/handle",
      namespaces: { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                    "xmlns:dok" => "http://www.dokus.pl/dokumenty/ws/dokumenty_wewnetrzne", 
                    "xmlns:dok1" => "http://www.dokus.pl/dokumenty/mt/dokumenty_wewnetrzne", 
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
      "dok1:tytul" => "#{self.esod_internal_letter.tytul}", 
      "dok1:uwagi" => "#{self.esod_internal_letter.uwagi}", 
      "dok1:identyfikatorRodzajuDokumentuWewnetrznego" => "#{self.esod_internal_letter.identyfikator_rodzaju_dokumentu_wewnetrznego}",
      "dok1:idDCMD" => "#{self.esod_internal_letter.identyfikator_typu_dcmd}",
      "dok1:identyfikatorDostepnosciDokumentu" => "#{self.esod_internal_letter.identyfikator_dostepnosci_dokumentu}",
      "dok1:pelnaWersjaCyfrowa" => "#{self.esod_internal_letter.pelna_wersja_cyfrowa}",
      "dok1:identyfikatorSprawy" => "#{self.sprawa}"
      }

    response = client.call(:utworz_dokument_wewnetrzny,  message: message_body )

    if response.success?
      response.xpath("//*[local-name()='utworzDokumentWewnetrznyResponse']").each do |row|
        self.esod_internal_letter.data_utworzenia = row.xpath("./*[local-name()='dataUtworzenia']").text
        self.esod_internal_letter.identyfikator_osoby_tworzacej = row.xpath("./*[local-name()='identyfikatorOsobyTworzacej']").text
        self.esod_internal_letter.data_modyfikacji = row.xpath("./*[local-name()='dataModyfikacji']").text
        self.esod_internal_letter.identyfikator_osoby_modyfikujacej = row.xpath("./*[local-name()='identyfikatorOsobyModyfikujacej']").text
        self.esod_internal_letter.numer_ewidencyjny = row.xpath("./*[local-name()='numerEwidencyjny']").text
        self.esod_internal_letter.nrid = row.xpath("./*[local-name()='nrid']").text 
        self.esod_internal_letter.save
        self.sygnatura = row.xpath("./*[local-name()='sygnatura']").text
        self.dokument = self.esod_internal_letter.nrid
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
