require 'esodes'

class PdfExaminationProtocolR < Prawn::Document

  def initialize(examinations, exam, view)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    super(:page_size => "A4", :page_layout => :portrait)
    #super()
    @examinations = examinations
    @exam = exam
    @view = view
    @divisions_str = Division.where(id: @examinations.map(&:division_id).uniq).order(:short_name).map(&:short_name).join(', ')

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
      title
      footer
      text "Strona #{page_number} / #{page_count}", size: 7, :align => :left, :valign => :bottom  
    end

  end

  def display_data_table
    bounding_box([0, 627], :width => 525, :height => 618) do 
      if table_data.empty?
        text "No Events Found"
      else
        table( table_data,
              :header => 1,   # True or 1... ilość wierszy jako nagłowek
              :column_widths => [23, 110, 36, 294, 62],
              #:row_colors => ["ffffff", "c2ced7"],
              :cell_style => { size: 9, :border_width => 0.5 }
            ) do
          columns(0).align = :right
          columns(1).align = :left
          columns(2).align = :left
          columns(3).align = :left
          columns(3).size = 7
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
                    ["Lp.",
                     "Nazwisko i imię",
                     "Rodzaj świad.",
                     "Przedmioty w/g karty egzaminacyjnej - Ocena: [Pozytywna/Negatywna]",
                     "Wynik egzaminu"]
                    ] + 
                     @examinations.map { |p| [ 
                        next_lp, 
                        name_with_last_exam(p),
                        p.division.short_name,
                        grades_sub(p),
                        p.examination_result_name
                      ] }
  end

  def name_with_last_exam(e)
    res = "#{e.customer.name}" + "\n" + "#{e.customer.given_names}"
    if Esodes::CORRECTION_EXAMINATIONS.include?(e.esod_category)
      customer_last_examination = Examination.where(customer: e.customer, division: e.division, examination_result: 'N').last
      res += "\n" + "(P: #{customer_last_examination.exam.number})" if customer_last_examination.present?
    end
    res
  end

  def grades_sub(examination)
    sub_data = sub_item_rows(examination)
    make_table(sub_data, :cell_style => { :border_width => 0.5 }) do
       columns(0).width = 274
       columns(0).size = 7
       columns(1).width = 20
    end   
  end

  def sub_item_rows(examination)
   examination.grades.order(:id).map do |sub_item|
      ["#{sub_item.subject.item}. #{sub_item.subject.name}", "#{sub_item.grade_result}"] 
    end  
  end


  def next_lp
    @lp = @lp +1
    return @lp 
  end

  def display_total_table
    h = 130 + 15*@exam.examiners.size
    if cursor < h  # domyslna czcionka to 10 a komisje pisze 8-ką
      start_new_page 
      #move_down 180
    end

    bounding_box([0, cursor], :width => 525, :height => h ) do
      move_down 15
      text "Członkowie Komisji Egzaminacyjnej", :align => :center

      move_down 12    
      text_box "1. Przewodniczący sesji:",      :at => [ 20, cursor], :width => 115, :height => 12, size: 9, :align => :left
      text_box "#{@exam.chairman}",             :at => [150, cursor], :width => 190, :height => 12, size: 10, :align => :left
      move_down 2    
      text_box "." * 80,                        :at => [345, cursor], :width => 190, :height => 12, size: 6, :align => :left

      move_down 15  
      text_box "2. Sekretarz sesji:",           :at => [ 20, cursor], :width => 115, :height => 12, size: 9, :align => :left  
      text_box "#{@exam.secretary}",            :at => [150, cursor], :width => 190, :height => 12, size: 10, :align => :left
      move_down 2    
      text_box "." * 80,                        :at => [345, cursor], :width => 190, :height => 12, size: 6, :align => :left  


      @exam.examiners.order(:name).each_with_index do |examiner, i|
        move_down 15  
        text_box "#{i+3}. Członek:",              :at => [ 20, cursor], :width => 115, :height => 12, size: 9, :align => :left  
        text_box "#{examiner.name}",              :at => [150, cursor], :width => 190, :height => 12, size: 10, :align => :left
        move_down 2    
        text_box "." * 80,                        :at => [345, cursor], :width => 190, :height => 12, size: 6, :align => :left  
      end


      move_down 45  
      text_box "." * 200,                                           :at => [295, cursor], :width => 225, :height => 12, size: 6, :align => :left  
      move_down 7    
      text_box "Zatwierdził Przewodniczący Komisji Egzaminacyjnej", :at => [300, cursor], :width => 225, :height => 12, size: 8, :align => :left

      #transparent(0.1) { stroke_bounds }
    end   
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
    text "#{@exam.place_and_date}", size: 11, :valign => :top, :align => :right
  end

  def title
    move_down 35
    text "PROTOKÓŁ Nr #{@exam.number}", size: 13, :align => :center
    move_down 10    
    text "KOMISJI EGZAMINACYJNEJ D/S OPERATORÓW URZĄDZEŃ RADIOWYCH", size: 13, :align => :center    
    text "W SŁUŻBIE RADIOKOMUNIKACYJNEJ AMATORSKIEJ", size: 13, :align => :center    
    move_down 10    
    text "Egzamin przeprowadzono #{@exam.date_exam} w #{@exam.place_exam}", size: 9
    text "Rodzaj świadectwa: #{@divisions_str}"
  end

  def footer
    stroke_line [0, 10], [525,10], self.line_width = 0.1
    text "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE-BI-WUSA (B&J) 2015", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

end
