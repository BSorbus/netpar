require 'esodes'

class PdfCertificateStatistic < Prawn::Document

  def initialize(category, date_start, date_end, view)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    super(:page_size => "A4", :page_layout => :portrait)
    #super(:page_size => "A4", :page_layout => :landscape)
    #super()
    @certificates = Certificate.where(category: category.upcase, date_of_issue: date_start..date_end).order(:date_of_issue, :number)
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
              :column_widths => [33, 100, 36, 290, 66],
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
      #display_total_table  
    end  
  end

  def table_data
    @lp = 0
    table_data ||= [
                    ["Lp.",
                     "Numer",
                     "Rodzaj świad.",
                     "Nazwisko i imię",
                     "Data Wydania Ważności"]
                    ] + 
                     @certificates.map { |p| [ 
                        next_lp, 
                        p.number,
                        Esodes::RENEWING_EXAMINATIONS.include?(p.esod_category) ? "#{p.division.short_name}" + "\n" + "(PW)" : p.division.short_name,
                        customer_name(p),
                        certificate_dates(p)
                      ] }
  end

  def customer_name(e)
    "#{e.customer.name}" + "\n" + "#{e.customer.given_names}"
  end

  def certificate_dates(e)
    "#{e.date_of_issue}" + "\n" + "#{e.valid_thru}"
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
     text "Wykaz świadectw #{category_name(cat.upcase)}" + "\n" + "data wydania: #{d_start} -:- #{d_end}", size: 13, :align => :right
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
