module Esodes

  # instancja testowa
  # 10.60.0.105:443" LB sprzetowy ESB-TEST (uwaga! inny port)
  # 10.40.2.4:8443 LB programowy 
  # 10.40.2.5:8243(epl-tesb1) i 
  # 10.40.2.6:8243(epl-tesb2) 

  # instancja produkcyjna
  # 10.60.0.135:443" # LB sprzetowy ESB
  # 10.40.1.4:443 LB 
  # 10.40.1.5:8243(epl-esb1) i 
  # 10.40.1.6:8243(epl-esb2) 

      API_SERVER = "https://10.60.0.135:443" # LB sprzetowy (F5)
      #  API_SERVER = "https://10.60.0.105:443" # LB sprzetowy TEST (F5)

      #  API_SERVER = "https://10.40.1.4:443"  # LB programowy starej ESB
      #  API_SERVER = "https://10.40.2.4:8443" # LB programowy starej ESB-TEST

  API_TOKEN_EXPIRE = 590.seconds    #  10.minutes
#  API_SYSTEM_USER = "admin"
#  API_SYSTEM_USER_PASS = "admin"
#  admin:admin
#  YWRtaW46YWRtaW4=
#  zz_Intranet:Intr@43L
#  enpfSW50cmFuZXQ6SW50ckA0M0w=

  API_SYSTEM_USER = "zz_Netpar2015"
  API_SYSTEM_USER_PASS = "%gBcD32Sx"
#  zz_Netpar2015:%gBcD32Sx
#  enpfTmV0cGFyMjAxNTolZ0JjRDMyU3g=


  # Wniosek o wydanie świadectwa (41)
  # Wniosek o egzamin poprawkowy (42)
  # Wniosek o odnowienie bez egzaminu (43)
  # Wniosek o odnowienie z egzaminem (44) #(PW)
  # Wniosek o odnowienie z egzaminem, poprawkowy (49) #(PW)
  # Wniosek o wydanie świadectwa - egzamin poza UKE (50)
  # Wniosek o duplikat (45)
  # Wniosek o wymianę świadectwa (46)
  # Sesja egzaminacyjna (47)
  # Protokół egzaminacyjny (48)

  EGZAMIN = 41
  POPRAWKOWY = 42
  ODNOWIENIE_BEZ_EGZAMINU = 43
  ODNOWIENIE_Z_EGZAMINEM = 44 
  ODNOWIENIE_Z_EGZAMINEM_POPRAWKOWY = 49
  SWIADECTWO_BEZ_EGZAMINU = 50
  DUPLIKAT = 45
  WYMIANA = 46
  SESJA = 47
  PROTOKOL = 48
  SESJA_BEZ_EGZAMINOW = 101

  ORDINARY_EXAMINATIONS = [EGZAMIN, ODNOWIENIE_Z_EGZAMINEM]
  CORRECTION_EXAMINATIONS = [POPRAWKOWY, ODNOWIENIE_Z_EGZAMINEM_POPRAWKOWY]
  RENEWING_EXAMINATIONS = [ODNOWIENIE_Z_EGZAMINEM, ODNOWIENIE_Z_EGZAMINEM_POPRAWKOWY]
  ALL_CATEGORIES_EXAMINATIONS = [EGZAMIN, POPRAWKOWY, ODNOWIENIE_Z_EGZAMINEM, ODNOWIENIE_Z_EGZAMINEM_POPRAWKOWY]

  WITHOUT_EXAMINATIONS = [SESJA_BEZ_EGZAMINOW]
  ALL_CATEGORIES_EXAMS = [SESJA, SESJA_BEZ_EGZAMINOW]

  ALL_CATEGORIES_CERTIFICATES = [ODNOWIENIE_BEZ_EGZAMINU, SWIADECTWO_BEZ_EGZAMINU, DUPLIKAT, WYMIANA]
  ALL_CATEGORIES_EXAMINATIONS_AND_CERTIFICATES = [EGZAMIN, ODNOWIENIE_Z_EGZAMINEM, POPRAWKOWY, ODNOWIENIE_Z_EGZAMINEM_POPRAWKOWY, ODNOWIENIE_BEZ_EGZAMINU, SWIADECTWO_BEZ_EGZAMINU, DUPLIKAT, WYMIANA]


  ACTION_NEW = [EGZAMIN, POPRAWKOWY, ODNOWIENIE_Z_EGZAMINEM, ODNOWIENIE_Z_EGZAMINEM_POPRAWKOWY, SWIADECTWO_BEZ_EGZAMINU, SESJA]
  ACTION_EDIT = [ODNOWIENIE_BEZ_EGZAMINU, DUPLIKAT, WYMIANA, PROTOKOL]

  JRWA_L = [5430]
  JRWA_M = [5411] # JRWA_M = [5431]
  JRWA_R = [5412] # JRWA_R = [5432]
  JRWA_ALL = [5430, 5411, 5412] #  JRWA_ALL = [5430, 5431, 5432]

  DEFAULT_SPOSOB_PRZESLANIA_IF_PROPOSAL = 78


  def self.log_soap_error(error_obj, options = {}) 
    Rails.logger.fatal "=" * 80
    Rails.logger.fatal "ERROR #{Time.current}"
    Rails.logger.fatal "file: #{options[:file]}" if options[:file].present? 
    Rails.logger.fatal "function: #{options[:function]}" if options[:function].present? 
    Rails.logger.fatal "soap function: #{options[:soap_function]}" if options[:soap_function].present? 
    Rails.logger.fatal "error: #{error_obj.class.name}" 
    Rails.logger.fatal "#{error_obj.inspect}" 
    if ['Savon::HTTPError'].include?("#{error_obj.class.name}")
      Rails.logger.fatal "error_obj.http.code: #{error_obj.http.code}"
    end
    if ['Savon::SOAPFault', 'Savon::InvalidResponseError', 'Savon::Error'].include?("#{error_obj.class.name}")
      Rails.logger.fatal "error_obj.http.code: #{error_obj.http.code}"
      Rails.logger.fatal "faultcode: #{error_obj.to_hash[:fault][:faultcode]}"
      Rails.logger.fatal "faultstring: #{error_obj.to_hash[:fault][:faultstring]}"
      Rails.logger.fatal "detail: #{error_obj.to_hash[:fault][:detail]}"
    end
    if options[:base_obj].present? 
      Rails.logger.fatal "#{options[:base_obj].class.name}"
      err_text = "#{error_obj.class.name} => #{error_obj.inspect}, error_obj.http.code: #{error_obj.http.code}"
      if error_obj.to_hash[:fault].present?
        err_text = err_text + ", faultcode: #{error_obj.to_hash[:fault][:faultcode]}, faultstring: #{error_obj.to_hash[:fault][:faultstring]}, detail: #{error_obj.to_hash[:fault][:detail]}"
      end
      options[:base_obj].errors.add(:base, "#{err_text}")
    end
    Rails.logger.fatal "=" * 80
  end


  def self.base64_user_and_pass
    Base64.encode64("#{API_SYSTEM_USER}:#{API_SYSTEM_USER_PASS}").delete!("\n")
  end

  def self.limit_time_add_to_exam(service) 
    case service.upcase
    when 'L'
      7.days
    when 'M'
      7.days
    when 'R'
      7.days
    else
      raise "Error value for Esodes::esod_matter_jrwa (#{service})!"
    end
  end

  def self.limit_time_add_to_examination(service) 
    case service.upcase
    when 'L'
      14.days
    when 'M'
      7.days
    when 'R'
      14.days
    else
      raise "Error value for Esodes::esod_matter_jrwa (#{service})!"
    end
  end

  def self.limit_time_add_to_certificate(service) 
    case service.upcase
    when 'L'
      14.days
    when 'M'
      7.days
    when 'R'
      14.days
    else
      raise "Error value for Esodes::esod_matter_jrwa (#{service})!"
    end
  end

  def self.esod_matter_iks_name(iks)
    case iks
    when EGZAMIN                  #41
      'Wniosek o wydanie świadectwa'
    when POPRAWKOWY               #42
      'Wniosek o egzamin poprawkowy'
    when ODNOWIENIE_BEZ_EGZAMINU  #43
      'Wniosek o odnowienie bez egzaminu'
    when ODNOWIENIE_Z_EGZAMINEM   #44
      'Wniosek o odnowienie z egzaminem' #(PW)
    when ODNOWIENIE_Z_EGZAMINEM_POPRAWKOWY #49
      'Wniosek o odnowienie z egzaminem, poprawkowy' #(PW)
    when SWIADECTWO_BEZ_EGZAMINU  #50
      'Wniosek o wydanie świadectwa - egzamin poza UKE'
    when DUPLIKAT                 #45
      'Wniosek o duplikat'
    when WYMIANA                  #46
      'Wniosek o wymianę świadectwa'
    when SESJA                    #47
      'Sesja egzaminacyjna'
    when SESJA_BEZ_EGZAMINOW      #101
      'Sesja bez egzaminu lub z egzaminem poza UKE'
    when PROTOKOL                 #48
      'Protokół egzaminacyjny'
    else
      #raise "Error value for Esodes::esod_matter_iks_name (#{iks})!"
      "#{iks}"
    end
  end

  def self.esod_matter_service_jrwa(service)
    case service.upcase
    when 'L'
      5430
    when 'M'
      5411
      # 5431
    when 'R'
      5412
      # 5432
    else
      raise "Error value for Esodes::esod_matter_jrwa (#{service})!"
    end
  end

  def self.esod_attached_file_category(type)
    # 1;"NIE OKREŚLONA"
    # 2;"Dokument"
    # 3;"Dokument - wizualizacja"
    # 4;"Załącznik"
    # 5;"Koperta"
    # 6;"Podpis"
    # 7;"Podpis - weryfikacja"
    # 8;"UPO"
    # 9;"UPO - wizualizacja"
    # 10;"UPD"
    # 11;"UPD - wizualizacja"
    # 12;"E-mail - surowy nagłówek"
    # 13;"E-mail - surowa treść"
    # 14;"Szablon"
    # 15;"Zwrotka ZPO"
    # 16;"Podpis otaczający(EPO)"
    # 17;"Struktura weryfikacji"
    # 18;"Plik tymczasowy"
    # 19;"Struktura walidacji ePUAP"
    # 20;"UPP"
    # 21;"UPP - wizualizacja"
    # 22;"Wizualizacja XML"
    # 23;"Dokument - ePUAP"
    # 24;"Dokument do podpisu"
    # 25;"List przewozowy"
    2
  end


  def self.rodzaj_dokumentu_przychodzacego_array
    my_array = []
    doc = Nokogiri::XML(File.open("app/models/esod/rodzaj_dokumentow_przychodzacych.xml")) do |config|
      config.strict.nonet
    end
    doc.xpath("//*[local-name()='return']").each do |ret|
      ret.xpath("//*[local-name()='rodzajDokumentuPrzychodzacego']").each do |row|
        my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                      nazwa: row.xpath("./*[local-name()='nazwa']").text }
      end    
    end    
    return my_array.sort_by{|e| e[:nazwa].upcase}
  end

  def self.rodzaj_dokumentu_wychodzacego_array
    my_array = []
    doc = Nokogiri::XML(File.open("app/models/esod/rodzaj_dokumentow_wychodzacych.xml")) do |config|
      config.strict.nonet
    end
    doc.xpath("//*[local-name()='return']").each do |ret|
      ret.xpath("//*[local-name()='rodzajDokumentuWychodzacego']").each do |row|
        my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                      nazwa: row.xpath("./*[local-name()='nazwa']").text }
      end    
    end    
    return my_array.sort_by{|e| e[:nazwa].upcase}
  end

  def self.rodzaj_dokumentu_wewnetrznego_array
    my_array = []
    doc = Nokogiri::XML(File.open("app/models/esod/rodzaj_dokumentow_wewnetrznych.xml")) do |config|
      config.strict.nonet
    end
    doc.xpath("//*[local-name()='rodzajDokumentuWewnetrznego']").each do |row|
      my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                    nazwa: row.xpath("./*[local-name()='nazwa']").text }
    end    
    return my_array.sort_by{|e| e[:nazwa].upcase}
  end

  def self.rodzaj_wysylki_array
    my_array = []
    doc = Nokogiri::XML(File.open("app/models/esod/rodzaj_wysylki.xml")) do |config|
      config.strict.nonet
    end
    doc.xpath("//*[local-name()='return']").each do |ret|
      ret.xpath("//*[local-name()='rodzajWysylki']").each do |row|
        my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                      nazwa: row.xpath("./*[local-name()='nazwa']").text }
      end    
    end    
    return my_array.sort_by{|e| e[:nazwa].upcase}
  end

  # DEFAULT_SPOSOB_PRZESLANIA_IF_PROPOSAL = 78
  def self.sposob_przeslania_array
    my_array = []
    doc = Nokogiri::XML(File.open("app/models/esod/sposob_przeslania.xml")) do |config|
      config.strict.nonet
    end
    doc.xpath("//*[local-name()='return']").each do |ret|
      ret.xpath("//*[local-name()='sposobPrzeslania']").each do |row|
        my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                      nazwa: row.xpath("./*[local-name()='nazwa']").text }
      end    
    end    
    return my_array.sort_by{|e| e[:nazwa].upcase}
  end

  def self.dostepnosc_dokumentu_array
    my_array = []
    doc = Nokogiri::XML(File.open("app/models/esod/dostepnosc_dokumentu.xml")) do |config|
      config.strict.nonet
    end
    doc.xpath("//*[local-name()='return']").each do |ret|
      ret.xpath("//*[local-name()='dostepnoscDokumentow']").each do |row|
        my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                      nazwa: row.xpath("./*[local-name()='nazwa']").text }
      end    
    end    
    return my_array.sort_by{|e| e[:nazwa].upcase}
  end



  def self.esod_whenever_sprawy(user_id, days_back)
    days_back ||= 30.days
    date_step = 1.day
    start_date = Time.current - days_back
    end_date = start_date + date_step
    start_run = Time.current

    puts '----------------------------------------------------------------'
    puts "Esod::Matter.get_wyszukaj_sprawy_referenta(...)"
    puts "... for user_id: #{user_id}"

    Esodes::EsodTokenData.new(user_id)
    #if Esodes::EsodTokenData.response_token_errors.present?
    #  Esodes::EsodTokenData.response_token_errors.each do |err|
    #    puts "#{err}"
    #  end
    #  #break    
    #end
    while start_date < end_date
      Esod::Matter.get_wyszukaj_sprawy_referenta("#{start_date.iso8601}","#{end_date.iso8601}")
      if Esodes::EsodTokenData.response_token_errors.present?
        break
      end
      if end_date < Time.current
      start_date += date_step
        end_date += date_step 
      else
        break
      end
    end
    puts "START: #{start_run}  END: #{Time.current}"
    puts '----------------------------------------------------------------'
  end


  class EsodTokenData
    @netpar_user_id = nil
    @token_stanowiska = []
    @response_token_errors = []

    @rodzaj_dokumentu_przychodzacego = []
    @rodzaj_dokumentu_wychodzacego = []
    @rodzaj_dokumentu_wewnetrznego = []
    @rodzaj_wysylki = []
    @sposob_przeslania = []
    @dostepnosc_dokumentu = []

    def initialize(netpar_user_id)
      self.class.netpar_user_id = netpar_user_id || nil
    end

    def self.netpar_user_id
      @netpar_user_id
    end
    def self.netpar_user_id=(value)
      @netpar_user_id = value
    end

    def self.response_token_errors
      @response_token_errors
    end
    def self.response_token_errors=(value)
      @response_token_errors = value
    end

    def self.netpar_user
      User.find_by(id: self.netpar_user_id)
    end

    def self.reload_token_and_other
      responseToken = Esod::Token.new(self.netpar_user.email, self.netpar_user.esod_encryped_password)
      self.response_token_errors = responseToken.response_errors
      if self.response_token_errors.blank?
        self.netpar_user.update_columns(esod_token: responseToken.token_string, esod_token_expired_at: Time.current + API_TOKEN_EXPIRE) 
        # load stanowiska!
        self.token_stanowiska = responseToken.stanowiska
        #self.netpar_user.esod_token
      else
        self.netpar_user.update_columns(esod_token: nil, esod_token_expired_at: nil)
        self.token_stanowiska = []
      end
    end

    def self.token_string
      self.reload_token_and_other #if self.netpar_user.esod_token_expired_at.blank? || self.netpar_user.esod_token_expired_at <= Time.current || self.netpar_user.esod_token.blank? 
      self.netpar_user.esod_token
    end

    def self.token_stanowiska
      self.reload_token_and_other if self.netpar_user.esod_token_expired_at.blank? || self.netpar_user.esod_token_expired_at <= Time.current || @token_stanowiska.blank?
      @token_stanowiska
    end
    def self.token_stanowiska=(value)
      @token_stanowiska = value
    end

    def self.rodzaj_dokumentu_przychodzacego
      unless @rodzaj_dokumentu_przychodzacego != [] && @token_last_used + API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @rodzaj_dokumentu_przychodzacego = Esodes::rodzaj_dokumentu_przychodzacego_array #[ { :nrid=>"11", :nazwa=>"AAA"}, { :nrid=>"22", :nazwa=>"BBB"} ]
      end
      @rodzaj_dokumentu_przychodzacego 
    end

    def self.rodzaj_dokumentu_wychodzacego
      unless @rodzaj_dokumentu_wychodzacego != [] && @token_last_used + API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @rodzaj_dokumentu_wychodzacego = Esodes::rodzaj_dokumentu_wychodzacego_array
      end
      @rodzaj_dokumentu_wychodzacego 
    end

    def self.rodzaj_dokumentu_wewnetrznego
      unless @rodzaj_dokumentu_wewnetrznego != [] && @token_last_used + API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @rodzaj_dokumentu_wewnetrznego = Esodes::rodzaj_dokumentu_wewnetrznego_array
      end
      @rodzaj_dokumentu_wewnetrznego 
    end

    def self.rodzaj_wysylki
      unless @rodzaj_wysylki != [] && @token_last_used + API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @rodzaj_wysylki = Esodes::rodzaj_wysylki_array
      end
      @rodzaj_wysylki 
    end

    def self.sposob_przeslania
      unless @sposob_przeslania != [] && @token_last_used + API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @sposob_przeslania = Esodes::sposob_przeslania_array
      end
      @sposob_przeslania 
    end

    def self.dostepnosc_dokumentu
      unless @dostepnosc_dokumentu != [] && @token_last_used + API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @dostepnosc_dokumentu = Esodes::dostepnosc_dokumentu_array
      end
      @dostepnosc_dokumentu 
    end

  end


end
