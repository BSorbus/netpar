require 'esodes'

class PdfExaminationAttestationsR < Prawn::Document

  def initialize(current_user, examinations, exam, view)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    super(:page_size => "A4", :page_layout => :portrait)
    #super()
    @current_user = current_user
    @examinations = examinations
    @exam = exam
    @view = view

    font_families.update("DejaVu Sans" => {
      :normal => "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf", 
      :bold  => "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
      :italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf",
      :bold_italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-BoldOblique.ttf"
    })
    font "DejaVu Sans", size: 10


    count_rows = @examinations.length

    @examinations.each_with_index do |examination, i|
      data(examination, i)
      start_new_page if ((i+1) < count_rows)
    end

    repeat(:all, :dynamic => true) do
      logo
      header_right_corner
      title
      static_text
      footer
    end

  end

  def logo
    #logopath =  "#{Rails.root}/app/assets/images/pop_logo.png"
    #image logopath, :width => 197, :height => 91
    #image "#{Rails.root}/app/assets/images/uke_logo.png", :at => [430, 760]
    #image "#{Rails.root}/app/assets/images/logo_big.png", :height => 50
    #image "#{Rails.root}/app/assets/images/orzel.jpg", :height => 50, :position => :center
    # image "#{Rails.root}/app/assets/images/orzel.jpg", :height => 50, at: [100, 760]
    image "#{Rails.root}/app/assets/images/orzel_with_text.jpg", :height => 100, :valign => :top, :align => :left
  end

  def header_right_corner
    move_up 100
    # text "#{@exam.place_and_date}", size: 11, :valign => :top, :align => :right
    text "#{@current_user.department.address_city}, dn. #{@exam.date_exam}", size: 11, :valign => :top, :align => :right
  end

  def title
    move_down 125
    text "ZAŚWIADCZENIE O ZDANIU EGZAMINU", size: 12, :align => :center, :style => :bold
  end


  def data(examination, i)
    # move_down 150
    # # text "KARTA EGZAMINACYJNA NR* #{(i + 1).to_s}/#{@exam.number}", size: 12, :align => :center    
    # text "ZAŚWIADCZENIE O ZDANIU EGZAMINU", size: 12, :align => :center, :style => :bold    

    # move_down 20
    # text "#{examination.customer.fullname}", size: 11, :style => :bold 
    # move_down 5
    # text "ubiega się o #{examination.division.name}"

    move_down 170
    text "Prezes Urzędu Komunikacji Elektronicznej zaświadcza, że:", size: 11, :style => :bold
    text "The President of the Office of Electronic Communications declares herewith that:"
    text "Le Président de l'Office de Communications Electroniques certifie que:"
    text "Der Präsident der Behörde für Elektronische Kommunikation erklärt hiermit:"
    move_down 10
    # text "imię i nazwisko: #{examination.customer.fullname}", size: 11, :style => :bold
    text "imię i nazwisko: #{examination.proposal.given_names} #{examination.proposal.name}", size: 11, :style => :bold
    text "name / nom / name", size: 11
    move_down 5
    text "data urodzenia: #{examination.customer.birth_date}", size: 11, :style => :bold
    text "birth date / date de naissance / Geburtsdatum (yyyy-mm-dd)", size: 11

    # category "1"
    if ['A','1'].include?("#{examination.division.short_name}")
      move_down 10
      text "złożył(a) z wynikiem pozytywnym, egzamin z wiedzy i umiejętności, z zakresu obsługi " +
           "urządzeń radiowych w służbie radiokomunikacyjnej amatorskiej, uprawniający do ubiegania " +
           "się o pozwolenie kategorii 1 w służbie radiokomunikacyjnej amatorskiej, zgodnie z " +
           "wymaganiami Międzynarodowego Związku Telekomunikacyjnego (ITU). Złożony egzamin " +
           "odpowiada wymaganiom egzaminacyjnym, określonym w zaleceniu CEPT T/R 61-02 (HAREC)."
      move_down 3
      text "has successfully passed an amateur radio examination which fulfils the requirements laid " +
           "down by the International Telecommunication Union (ITU). The passed examination " +
           "corresponds to the examination described in CEPT Recommendation T/R 61-02 (HAREC)."
      move_down 3
      text "a réussi un examen de radioamateur conformément au règlement de I'Union internationale " +
           "des télécommunications (UIT). L’épreuve en question correspond à I'examen décrit dans la " +
           "Recommandation CEPT T/R 61-02 (HAREC)."
      move_down 3
      text "eine Amateurfunkprüfung erfoIgreich abgelegt hat, welche den Erfordernissen entspricht, wie " +
           "sie von der Internationalen Fernmeldeunion (ITU) festgelegt sind. Die abgelegte Prüfung " +
           "entspricht der in der CEPT– Empfehlung T/R 61-02 (HAREC)."
      # ./category "1"
    end

    if ['C','3'].include?("#{examination.division.short_name}")
      move_down 10
      text "złożył(a) z wynikiem pozytywnym, egzamin z wiedzy i umiejętności, z zakresu obsługi urządzeń " +
           "radiowych w służbie radiokomunikacyjnej amatorskiej, uprawniający do ubiegania się o " + 
           "pozwolenie kategorii 3 w służbie radiokomunikacyjnej amatorskiej, zgodnie z wymaganiami " +
           "Międzynarodowego Związku Telekomunikacyjnego (ITU). Złożony egzamin odpowiada " + 
           "wymaganiom egzaminacyjnym, określonym w ERC Report 32."
      move_down 3
      text "has successfully passed an amateur radio examination which fulfils the requirements laid " +
           "down by the International Telecommunication Union (ITU). The passed examination " +
           "corresponds to the examination described in ERC Report 32."
      move_down 3
      text "a réussi un examen de radioamateur conformément au règlement de I'Union internationale " +
           "des télécommunications (UIT). L’épreuve en question correspond à I'examen décrit dans le " +
           "rapport ERC Report 32."
      move_down 3
      text "eine Amateurfunkprüfung erfoIgreich abgelegt hat, welche den Erfordernissen entspricht, wie " +
           "sie von der Internationalen Fernmeldeunion (ITU) festgelegt sind. Die abgelegte Prüfung " +
           "entspricht der im ERC Report 32."
      # ./category "3"
    end

  end


  def static_text
    # move_down 530

    draw_text "Z upoważnienia Prezesa UKE", :at => [275, 240]

    draw_text "Urząd Komunikacji Elektronicznej", :at => [195, 70], size: 8
    draw_text "Warszawa, ul. Giełdowa 7/9", :at => [205, 58], size: 8
    draw_text "tel. 22 53 49 125, fax 22 53 49 175, platforma e-usług: pue.uke.gov.pl", :at => [120, 46], size: 8

  end

  def footer
    stroke_line [0, 10], [525,10], self.line_width = 0.1
    text "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE 2024", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

end
