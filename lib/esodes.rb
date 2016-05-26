module Esodes

  #1) Wniosek o wydanie świadectwa (41)
  #2) Wniosek o egzamin poprawkowy (42)
  #3) Wniosek o odnowienie bez egzaminu (43)
  #4) Wniosek o odnowienie z egzaminem (44) #(PW)
  #9) Wniosek o odnowienie z egzaminem, poprawkowy (49) #(PW)
  #10) Wniosek o wydanie świadectwa - egzamin poza UKE (50)
  #5) Wniosek o duplikat (45)
  #6) Wniosek o wymianę świadectwa (46)
  #7) Sesja egzaminacyjna (47)
  #8) Protokół egzaminacyjny (48)

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

  ACTION_NEW = [EGZAMIN, POPRAWKOWY, ODNOWIENIE_Z_EGZAMINEM, ODNOWIENIE_Z_EGZAMINEM_POPRAWKOWY, SWIADECTWO_BEZ_EGZAMINU, SESJA]
  ACTION_EDIT = [ODNOWIENIE_BEZ_EGZAMINU, DUPLIKAT, WYMIANA, PROTOKOL]

  JRWA_L = [5430]
  JRWA_M = [5431]
  JRWA_R = [5432]

  ESOD_API_SERVER = "http://testesod.uke.gov.pl"
  ESOD_API_TOKEN_EXPIRE = 590.seconds    #  10.minutes

  def self.limit_time_add_to_exam(service) 
    case service.upcase
    when 'L'
      7.days
    when 'M'
      3.days
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
      6.days
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
      6.days
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
      5431
    when 'R'
      5432
    else
      raise "Error value for Esodes::esod_matter_jrwa (#{service})!"
    end
  end



  def self.rodzaj_dokumentu_przychodzacego_array
    my_array = []
    doc = Nokogiri::XML(File.open("app/models/esod/rodzaj_dokumentow_przychodzacych.xml")) do |config|
      config.strict.nonet
    end
    doc.xpath("//*[local-name()='rodzajDokumentuPrzychodzacego']").each do |row|
      my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                    nazwa: row.xpath("./*[local-name()='nazwa']").text }
    end    
    return my_array.sort_by{|e| e[:nazwa].upcase}
  end

  def self.rodzaj_dokumentu_wychodzacego_array
    my_array = []
    doc = Nokogiri::XML(File.open("app/models/esod/rodzaj_dokumentow_wychodzacych.xml")) do |config|
      config.strict.nonet
    end
    doc.xpath("//*[local-name()='rodzajDokumentuWychodzacego']").each do |row|
      my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                    nazwa: row.xpath("./*[local-name()='nazwa']").text }
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
    doc.xpath("//*[local-name()='rodzajWysylki']").each do |row|
      my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                    nazwa: row.xpath("./*[local-name()='nazwa']").text }
    end    
    return my_array.sort_by{|e| e[:nazwa].upcase}
  end

  def self.sposob_przeslania_array
    my_array = []
    doc = Nokogiri::XML(File.open("app/models/esod/sposob_przeslania.xml")) do |config|
      config.strict.nonet
    end
    doc.xpath("//*[local-name()='sposobPrzeslania']").each do |row|
      my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                    nazwa: row.xpath("./*[local-name()='nazwa']").text }
    end    
    return my_array.sort_by{|e| e[:nazwa].upcase}
  end

  def self.dostepnosc_dokumentu_array
    my_array = []
    doc = Nokogiri::XML(File.open("app/models/esod/dostepnosc_dokumentu.xml")) do |config|
      config.strict.nonet
    end
    doc.xpath("//*[local-name()='dostepnoscDokumentu']").each do |row|
      my_array << { nrid:  row.xpath("./*[local-name()='nrid']").text,
                    nazwa: row.xpath("./*[local-name()='nazwa']").text }
    end    
    return my_array.sort_by{|e| e[:nazwa].upcase}
  end



  def self.esod_whenever_sprawy(user_id)
    date_step = 1.day
    start_date = Date.parse('2016-04-01')
    end_date = start_date + date_step

    Esodes::EsodTokenData.new(netpar_user_id: user_id)

    while start_date < end_date
      Esod::Matter.get_wyszukaj_sprawy_referenta("#{start_date}","#{end_date}")
      if end_date < Time.current
      start_date += date_step
        end_date += date_step 
      else
        break
      end
    end
  end


  class EsodTokenData
    @netpar_user_id = nil
    @netpar_user = nil

    @token_last_used = Time.current - 1.year
    @token_string = ""
    @token_stanowiska = []

    @rodzaj_dokumentu_przychodzacego = []
    @rodzaj_dokumentu_wychodzacego = []
    @rodzaj_dokumentu_wewnetrznego = []
    @rodzaj_wysylki = []
    @sposob_przeslania = []
    @dostepnosc_dokumentu = []

    def initialize(options = {})
      self.class.netpar_user_id = options[:netpar_user_id] || nil
      self.class.netpar_user = options[:netpar_user] || nil
      self.class.token_last_used = Time.current - 1.year
    end

    def self.token_last_used
      @token_last_used 
    end
    def self.token_last_used=(value)
      @token_last_used = value
    end

    def self.netpar_user_id
      @netpar_user_id
    end
    def self.netpar_user_id=(value)
      @netpar_user_id = value
    end

    def self.netpar_user
      if @netpar_user == nil || @netpar_user.id != self.netpar_user_id
        self.netpar_user = User.find_by(id: self.netpar_user_id)
      end
      @netpar_user 
    end
    def self.netpar_user=(value)
      @netpar_user = value
    end

    def self.token_string
      if @token_string == "" || self.token_last_used + ESOD_API_TOKEN_EXPIRE < Time.current
        self.token_last_used = Time.current
        responseToken = Esod::Token.new(self.netpar_user.email, self.netpar_user.esod_encryped_password)
        self.token_string = responseToken.token_string
        self.token_stanowiska = responseToken.stanowiska
      end
      @token_string
    end
    def self.token_string=(value)
      @token_string = value
    end

    def self.token_stanowiska
      if @token_stanowiska == [] || self.token_last_used + ESOD_API_TOKEN_EXPIRE < Time.current
        self.token_last_used = Time.current
        responseToken = Esod::Token.new(self.netpar_user.email, self.netpar_user.esod_encryped_password)
        self.token_string = responseToken.token_string
        self.token_stanowiska = responseToken.stanowiska
      end
      @token_stanowiska
    end
    def self.token_stanowiska=(value)
      @token_stanowiska = value
    end

    def self.rodzaj_dokumentu_przychodzacego
      unless @rodzaj_dokumentu_przychodzacego != [] && @token_last_used + ESOD_API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @rodzaj_dokumentu_przychodzacego = Esodes::rodzaj_dokumentu_przychodzacego_array #[ { :nrid=>"11", :nazwa=>"AAA"}, { :nrid=>"22", :nazwa=>"BBB"} ]
      end
      @rodzaj_dokumentu_przychodzacego 
    end

    def self.rodzaj_dokumentu_wychodzacego
      unless @rodzaj_dokumentu_wychodzacego != [] && @token_last_used + ESOD_API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @rodzaj_dokumentu_wychodzacego = Esodes::rodzaj_dokumentu_wychodzacego_array
      end
      @rodzaj_dokumentu_wychodzacego 
    end

    def self.rodzaj_dokumentu_wewnetrznego
      unless @rodzaj_dokumentu_wewnetrznego != [] && @token_last_used + ESOD_API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @rodzaj_dokumentu_wewnetrznego = Esodes::rodzaj_dokumentu_wewnetrznego_array
      end
      @rodzaj_dokumentu_wewnetrznego 
    end

    def self.rodzaj_wysylki
      unless @rodzaj_wysylki != [] && @token_last_used + ESOD_API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @rodzaj_wysylki = Esodes::rodzaj_wysylki_array
      end
      @rodzaj_wysylki 
    end

    def self.sposob_przeslania
      unless @sposob_przeslania != [] && @token_last_used + ESOD_API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @sposob_przeslania = Esodes::sposob_przeslania_array
      end
      @sposob_przeslania 
    end

    def self.dostepnosc_dokumentu
      unless @dostepnosc_dokumentu != [] && @token_last_used + ESOD_API_TOKEN_EXPIRE > Time.current
        @token_last_used = Time.current
        @dostepnosc_dokumentu = Esodes::dostepnosc_dokumentu_array
      end
      @dostepnosc_dokumentu 
    end

  end

end
