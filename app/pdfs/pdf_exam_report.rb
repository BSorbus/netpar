class PdfExamReport < Prawn::Document

  def initialize(exam, view)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    super(:page_size => "A4", :page_layout => :portrait)
    #super()
    @exam = exam
    @view = view
    @examinations = @exam.examinations
    @divisions = Division.where(id: @exam.examinations.map(&:division_id).uniq).order(:short_name).all
 

    font_families.update("DejaVu Sans" => {
      :normal => "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf", 
      :bold  => "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
      :italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf",
      :bold_italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-BoldOblique.ttf"
    })
    font "DejaVu Sans", size: 10

    bounding_box([0, 687], :width => 525, :height => 678) do 
      move_down 10
      text "Zarejestrowane pozycje egzaminacyjne: WSZYSTKIE", size: 12, :align => :left
      display_division_table
      move_down 15
      text "Pozycje egzaminacyjne z wynikiem POZYTYWNYM", size: 12, :align => :left
    end

    repeat(:all, :dynamic => true) do
      logo
      title
      footer
      text "Strona #{page_number} / #{page_count}", size: 7, :align => :left, :valign => :bottom  
    end

  end

  def display_division_table
    #bounding_box([0, 687], :width => 525, :height => 678) do 
      if table_division_data.empty?
        text "No Events Found"
      else
        table( table_division_data,
              :header => 1,   # True or 1... ilość wierszy jako nagłowek
              :column_widths => [305, 36, 92, 92],
              #:row_colors => ["ffffff", "c2ced7"],
              :cell_style => { size: 9, :border_width => 0.5 }
            ) do
          #columns(0).align = :right
          columns(0).align = :left
          columns(1).align = :left
          columns(2).align = :center
          columns(3).align = :center
          #columns(3).size = 7
          #row(0).font_style = :bold 
          row(0).size = 8 
          row(0).background_color = "C0C0C0"
          row(0).columns(2).align = :left
          row(0).columns(2).size = 7
          row(0).columns(3).align = :left
          row(0).columns(3).size = 7
          #row(0).columns(2).valign = :top
          #row(0).columns(2).align = :left
        end             
      end
      display_total_table_division
    #end  
  end

  def table_division_data
    table_data ||= [
                    ["Rodzaj świadectwa",
                     "Skrót",
                     "Zwykły /\n -||- Uzupełniający (PW)",
                     "Poprawkowy/\n -||- Uzupełniający (PW)"]
                    ] + 
                     @divisions.map { |p| [ 
                        p.name,
                        p.short_name,
                        "#{@examinations.where(division: p, examination_category: 'Z', supplementary: false).size}" +
                          " / " + "#{@examinations.where(division: p, examination_category: 'Z', supplementary: true).size}",
                        "#{@examinations.where(division: p, examination_category: 'P', supplementary: false).size}" +
                          " / " + "#{@examinations.where(division: p, examination_category: 'P', supplementary: true).size}",
                      ] }
  end

  def display_total_table_division
    #move_down 5    
    #stroke_line [350, cursor], [525,cursor], self.line_width = 2
    move_down 5    
    text_box "Razem:",                                                                        :at => [302, cursor], :width => 40, :height => 12, size: 9, :align => :right  
    text_box "#{@examinations.where(examination_category: 'Z', supplementary: false).size}",  :at => [355, cursor], :width => 20, :height => 12, size: 9, :style => :bold, :align => :right  
    text_box "#{@examinations.where(examination_category: 'P', supplementary: false).size}",  :at => [460, cursor], :width => 20, :height => 12, size: 9, :style => :bold, :align => :left  
    move_down 12    
    text_box "#{@examinations.where(examination_category: 'Z', supplementary: true).size}",   :at => [385, cursor], :width => 20, :height => 12, size: 9, :style => :bold, :align => :right  
    text_box "#{@examinations.where(examination_category: 'P', supplementary: true).size}",   :at => [490, cursor], :width => 20, :height => 12, size: 9, :style => :bold, :align => :left  
    move_down 12    
    stroke_line [300, cursor], [525,cursor], self.line_width = 2
    move_down 7    
    text_box "#{@examinations.where(examination_category: 'Z').size}",                        :at => [375, cursor], :width => 20, :height => 12, size: 9, :style => :bold, :align => :center  
    text_box "#{@examinations.where(examination_category: 'P').size}",                        :at => [470, cursor], :width => 20, :height => 12, size: 9, :style => :bold, :align => :center  
  end


  def logo
    #logopath =  "#{Rails.root}/app/assets/images/pop_logo.png"
    #image logopath, :width => 197, :height => 91
    #image "#{Rails.root}/app/assets/images/uke_logo.png", :at => [430, 760]
    image "#{Rails.root}/app/assets/images/logo_big.jpg", :height => 50
    #image "#{Rails.root}/app/assets/images/orzel.jpg", :height => 50, :position => :center
  end


  def title
    move_up 10
    text "Sesja Nr #{@exam.number} z dnia #{@exam.date_exam}", size: 13, :align => :center
  end

  def footer
    stroke_line [0, 10], [525,10], self.line_width = 0.1
    text "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE-BI-WUSA (B&J) 2015", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

end
