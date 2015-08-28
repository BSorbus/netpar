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
    #@kuku = @examinations.map(&:division_id)
    #@kuku = Division.where(id: @examinations.map(&:division_id)).all.map(&:short_name)
    #@kuku = Division.where(id: @examinations.map(&:division_id)).order(:short_name).all.map(&:short_name)
    #@kuku = Division.where(id: @examinations.map(&:division_id)).order(:short_name).all.map { |s| "#{s.short_name}" }
    #@kuku = Division.where(id: @examinations.map(&:division_id).uniq).order(:short_name).all.pluck(:short_name)
    #@kuku = Division.where(id: @examinations.map(&:division_id).uniq).order(:short_name).all.map { |s| "#{s.short_name}" }
    #@kuku = Division.where(id: @examinations.map(&:division_id).uniq).order(:short_name).all.pluck(:short_name).inspect
    @divisions_str = Division.where(id: @examinations.map(&:division_id).uniq).order(:short_name).all.map(&:short_name).join(', ')

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
      #static_text
      footer
      text "Strona #{page_number} / #{page_count}", size: 7, :align => :left, :valign => :bottom  
    end

  end

  def display_data_table
    bounding_box([0, 625], :width => 525, :height => 400) do 
      if table_data.empty?
        text "No Events Found"
      else
        table( table_data,
              :header => true,
              :column_widths => [20, 300, 100, 105],
              #:row_colors => ["ffffff", "c2ced7"],
              :cell_style => { size: 8, :border_width => 0.5 }
            ) do
          columns(0).align = :right
          columns(1).align = :left
          columns(2).align = :left
          row(0).font_style = :bold 
          row(0).align = :left 
          #row(0).background_color = "#FF0000"
        end             
      end
    end  
  end


  def table_data
    @lp = 0
    table_data ||= [["Lp",
                     "Przedmiot",
                     "Ocena (słownie)",
                     "Podpis egzaminatora"]] + 
                     @examinations.map { |p| [ 
                        next_lp, 
                        p.customer.fullname,
                        "",
                        p.examination_resoult_name
                      ] }
  end

  def next_lp
    @lp = @lp +1
    return @lp 
  end


  def logo
    #logopath =  "#{Rails.root}/app/assets/images/pop_logo.png"
    #image logopath, :width => 197, :height => 91
    #image "#{Rails.root}/app/assets/images/uke_logo.png", :at => [430, 760]
    image "#{Rails.root}/app/assets/images/logo_big.jpg", :height => 50
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
    text "W SŁUŻBIE RADIOKOMUNIKACYJNEJ AMATORSKIEJ ", size: 13, :align => :center    
    move_down 10    
    text "Egzamin przeprowadzono #{@exam.date_exam} w #{@exam.place_exam}", size: 9
    text "Rodzaj świadectwa: #{@divisions_str}"
  end


  def static_text
    move_down 330
    text "Potwierdzam zapoznanie się z przyznanymi mi ocenami oraz oświadczam, że zostałem/-am poinformowany/-a o:"
    text "1) wyniku egzaminu,"
    text "2) prawie przystąpienia do egzaminu poprawkowego oraz możliwych miejscach i terminach przeprowadzenia tego egzaminu**"



    draw_text "." * 100, :at => [20, 200], size: 6
    draw_text "podpis osoby ubiegającej się o świadectwo", :at => [30, 190], size: 7, :style => :italic

    draw_text "." * 220, :at => [20, 150], size: 6
    draw_text "data i podpis sekretarza sesji egzaminacyjnej w chwili odbioru karty od osoby ubiegającej się o świadectwo", :at => [30, 140], size: 7, :style => :italic


    draw_text "* Nr karty egzaminacyjnej wpisuje się zgodnie z liczbą przyporządkowaną w protokole sesji egzaminacyjnej.", :at => [5, 80], size: 8, :style => :italic
    draw_text "Karta egzaminacyjna podlega zwrotowi do sekretarza sesji egzaminacyjnej w czasie bieżącej sesji. Niezwrócenie karty jest", :at => [12,  70], size: 8, :style => :italic
    draw_text "równoznaczne z niezdaniem całego egzaminu.", :at => [12,  60], size: 8, :style => :italic

    draw_text "** W przypadku pozytywnego wyniku egzaminu pkt 2 należy skreślić", :at => [5, 40], size: 8, :style => :italic

  end

  def footer
    stroke_line [0, 10], [525,10], self.line_width = 0.1
    text "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE-BI-WUSA (B&J) 2015", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

end
