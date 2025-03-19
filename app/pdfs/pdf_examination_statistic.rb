require 'esodes'

class PdfExaminationStatistic < Prawn::Document

  def initialize(category, date_start, date_end, view)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    super(:page_size => "A4", :page_layout => :portrait)
    #super(:page_size => "A4", :page_layout => :landscape)
    #super()
    # @examinations = Certificate.where(category: category.upcase, date_of_issue: date_start..date_end).order(:date_of_issue, :number)
    @examinations = Examination.joins(:exam, :customer).
                      where.not(Exam.arel_table[:esod_category].in(Esodes::WITHOUT_EXAMINATIONS)).
                      where(Exam.arel_table[:category].eq(category.upcase)).
                      where(Exam.arel_table[:date_exam].between(date_start..date_end)).
                      order(Exam.arel_table[:date_exam], Exam.arel_table[:number], Customer.arel_table[:name], Customer.arel_table[:given_names])
    @view = view

    font_families.update("DejaVu Sans" => {
      :normal => "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf", 
      :bold  => "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
      :italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf",
      :bold_italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-BoldOblique.ttf"
    })
    font "DejaVu Sans", size: 10

    display_data_table

    repeat(:all, :dynamic => true) do
      logo
      header_right_corner
      title(category, date_start, date_end)
      footer
      text "Strona #{page_number} / #{page_count}", size: 7, :align => :left, :valign => :bottom  
    end

  end

  def display_data_table
    bounding_box([0, 710], :width => 525, :height => 699) do 
      if table_data.empty?
        text "Brak danych"
      else
        table( table_data,
              :header => 1,   # True or 1... ilość wierszy jako nagłowek
              :column_widths => [33, 129, 66, 36, 225, 36],
              #:row_colors => ["ffffff", "c2ced7"],
              :cell_style => { size: 9, :border_width => 0.5 }
            ) do
          columns(0).align = :right
          columns(1).align = :left
          columns(2).align = :left
          columns(3).align = :left
          #row(0).font_style = :bold 
          row(0).size = 8 
          row(0).background_color = "C0C0C0"
          #row(0).columns(2).valign = :top
          #row(0).columns(2).align = :left
        end             
      end
      display_total_table  
    end  
  end

  def table_data
    @lp = 0
    table_data ||= [
                    ["Lp.", "Numer", "Data sesji", "Rodzaj świad.", "Nazwisko i imię", "Wynik"]
                    ] + 
                     @examinations.map { |rec| [ 
                        next_lp, 
                        rec.exam.number,
                        rec.exam.date_exam.strftime("%Y-%m-%d"),
                        Esodes::RENEWING_EXAMINATIONS.include?(rec.esod_category) ? "#{rec.division.short_name}" + "\n" + "(PW)" : rec.division.short_name,
                        customer_name(rec),
                        rec.examination_result
                      ] }
  end

  def customer_name(e)
    "#{e.customer.name}" + "\n" + "#{e.customer.given_names}"
  end

  def next_lp
    @lp = @lp +1
    return @lp 
  end

  def display_total_table
    start_new_page 

    bounding_box([0, cursor], :width => 525, :height => 699 ) do
      move_down 15
      text "Podsumowanie", size: 13, :align => :center

      divisions = Division.where(id: @examinations.pluck(:division_id).uniq).order(:name)
      divisions.each_with_index do |division, i|
        move_down 20
        text_box "#{(i+1)}. #{division.name}:",   :at => [ 20, cursor], :width => 400, :height => 12, size: 10, :align => :left

        esod_categories = @examinations.where(division: division).pluck(:esod_category).uniq
        esod_categories.each_with_index do |esod_category, y|
          move_down 20
          text_box "#{(i+1)}.#{(y+1)}. #{Esodes::esod_matter_iks_name(esod_category)}:",   :at => [ 35, cursor], :width => 200, :height => 12, size: 10, :align => :left

          move_down 15
          text_box "B:",                            :at => [ 60, cursor], :width => 20, :height => 12, size: 10, :align => :left
          text_box "N:",                            :at => [120, cursor], :width => 20, :height => 12, size: 10, :align => :left
          text_box "O:",                            :at => [180, cursor], :width => 20, :height => 12, size: 10, :align => :left
          text_box "P:",                            :at => [240, cursor], :width => 20, :height => 12, size: 10, :align => :left
          text_box "Z:",                            :at => [300, cursor], :width => 20, :height => 12, size: 10, :align => :left
          text_box "brak wyniku:",                  :at => [360, cursor], :width => 120, :height => 12, size: 10, :align => :left

          examination_result_B_size = @examinations.where(division: division).where(esod_category: esod_category).
                                                    where(examination_result: "B").all.size
          text_box "#{examination_result_B_size}",  :at => [ 75, cursor], :width => 20, :height => 12, size: 10, :align => :left, :style => :bold

          examination_result_N_size = @examinations.where(division: division).where(esod_category: esod_category).
                                                    where(examination_result: "N").all.size
          text_box "#{examination_result_N_size}",  :at => [135, cursor], :width => 20, :height => 12, size: 10, :align => :left, :style => :bold

          examination_result_O_size = @examinations.where(division: division).where(esod_category: esod_category).
                                                    where(examination_result: "O").all.size
          text_box "#{examination_result_O_size}",  :at => [195, cursor], :width => 20, :height => 12, size: 10, :align => :left, :style => :bold

          examination_result_P_size = @examinations.where(division: division).where(esod_category: esod_category).
                                                    where(examination_result: "P").all.size
          text_box "#{examination_result_P_size}",  :at => [255, cursor], :width => 20, :height => 12, size: 10, :align => :left, :style => :bold

          examination_result_Z_size = @examinations.where(division: division).where(esod_category: esod_category).
                                                    where(examination_result: "Z").all.size
          text_box "#{examination_result_Z_size}",  :at => [315, cursor], :width => 20, :height => 12, size: 10, :align => :left, :style => :bold

          examination_result___size = @examinations.where(division: division).where(esod_category: esod_category).
                                                    where.not(examination_result: ["B","N","O","P","Z"]).all.size
          text_box "#{examination_result___size}",  :at => [430, cursor], :width => 20, :height => 12, size: 10, :align => :left, :style => :bold

        end
      end

      move_down 35
      exams_count = @examinations.pluck(:exam_id).uniq.size
      text_box "Ilość sesji:",    :at => [ 20, cursor], :width => 100, :height => 12, size: 10, :align => :left
      text_box "#{exams_count}",  :at => [ 80, cursor], :width => 100, :height => 12, size: 10, :align => :left, :style => :bold

      move_down 35
      text "legenda wyników:"
      text "B - Negatywny bez prawa do poprawki"
      text "N - Negatywny z prawem do poprawki"
      text "O - Nieobecny"
      text "P - Pozytywny (zaświadczenia)"
      text "Z - Zmiana terminu (zgłoszenie zamknięto)"
      text "brak wyniku - egzamin jeszcze się nie odbył lub wynik nie został wpisany"

    end

    #   move_down 7    
    #   text_box "Zatwierdził przewodniczący sesji", :at => [300, cursor], :width => 225, :height => 12, size: 8, :align => :left

    #   #transparent(0.1) { stroke_bounds }
  end


  def logo
    #logopath =  "#{Rails.root}/app/assets/images/pop_logo.png"
    #image logopath, :width => 197, :height => 91
    #image "#{Rails.root}/app/assets/images/uke_logo.png", :at => [430, 760]
    image "#{Rails.root}/app/assets/images/logo_big.png", :height => 50
    #image "#{Rails.root}/app/assets/images/orzel.jpg", :height => 50, :position => :center
  end

  def header_right_corner
    move_up 50
    #text "#{@exam.place_and_date}", size: 11, :valign => :top, :align => :right
    text "#{Time.zone.today}", size: 11, :valign => :top, :align => :right
  end

  def title(cat, d_start, d_end)
    # move_down 35
    # text "PROTOKÓŁ Nr #{@exam.number}", size: 13, :align => :center
    # move_down 10    
    # text "KOMISJI EGZAMINACYJNEJ D/S OPERATORÓW URZĄDZEŃ RADIOWYCH", size: 13, :align => :center    
    # text "W SŁUŻBIE RADIOKOMUNIKACYJNEJ MORSKIEJ I ŻEGLUGI ŚRÓDLĄDOWEJ", size: 13, :align => :center    
    # move_down 10    
    # text "Egzamin przeprowadzono #{@exam.date_exam} w #{@exam.place_exam}", size: 9
    # text "Rodzaj świadectwa: #{@divisions_str}"

    move_down 10
     text "Wykaz osób przystępujących do egzaminu #{category_name(cat.upcase)}" + "\n" + "- sesje egzaminacyjne: #{d_start} -:- #{d_end}", size: 13, :align => :right
  end

  def footer
    stroke_line [0, 10], [525,10], self.line_width = 0.1
    text "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE-BI-WUSA (B&J) 2015", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

  def category_name(p)
    case p
    when 'l', 'L'
      '"LOT"'
    when 'r', 'R'
      '"RA"'
    when 'm', 'M'
      '"MOR"'
    else
      'Error !'
    end  
  end

end
