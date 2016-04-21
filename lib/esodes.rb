module Esodes

  #1) Wniosek o wydanie świadectwa (41)
  #2) Wniosek o egzamin poprawkowy (42)
  #3) Wniosek o odnowienie bez egzaminu (43)
  #4) Wniosek o odnowienie z egzaminem (44) #(PW)
  #9) Wniosek o odnowienie z egzaminem, poprawkowy (49) #(PW)
  #5) Wniosek o duplikat (45)
  #6) Wniosek o wymianę świadectwa (46)
  #7) Sesja egzaminacyjna (47)
  #8) Protokół egzaminacyjny (48)

  EGZAMIN = 41
  POPRAWKOWY = 42
  ODNOWIENIE_BEZ_EGZAMINU = 43
  ODNOWIENIE_Z_EGZAMINEM = 44 #PW
  ODNOWIENIE_Z_EGZAMINEM_POPRAWKOWY = 49
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

  ALL_CATEGORIES_CERTIFICATES = [ODNOWIENIE_BEZ_EGZAMINU, DUPLIKAT, WYMIANA]

  JRWA_L = [5430]
  JRWA_M = [5431]
  JRWA_R = [5432]

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


end
