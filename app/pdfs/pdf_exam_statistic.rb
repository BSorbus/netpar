require 'esodes'

class PdfExamStatistic < Prawn::Document

  def initialize(category, date_start, date_end, view)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    super(:page_size => "A4", :page_layout => :portrait)
    #super(:page_size => "A4", :page_layout => :landscape)
    #super()
    @exams = Exam.where(category: category.upcase, date_exam: date_start..date_end).where.not(esod_category: Esodes::WITHOUT_EXAMINATIONS).order(:date_exam, :number)
    @exams_without_examinations = Exam.where(category: category.upcase, date_exam: date_start..date_end, esod_category: Esodes::WITHOUT_EXAMINATIONS).order(:date_exam, :number)
    @view = view
 

    font_families.update("DejaVu Sans" => {
      :normal => "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf", 
      :bold  => "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
      :italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf",
      :bold_italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-BoldOblique.ttf"
    })
    font "DejaVu Sans", size: 10

    bounding_box([0, 710], :width => 525, :height => 699) do 
    #bounding_box([0, 462], :width => 770, :height => 451) do 
      text '1. Typ sesji: "' + (Esodes::ALL_CATEGORIES_EXAMS-Esodes::WITHOUT_EXAMINATIONS).map {|p| Esodes::esod_matter_iks_name(p) }.join(", ") + '"', size: 11, :align => :left
      display_exams_with_examinations_table

      #move_down 5
      start_new_page
      text '2. Typ sesji: "' + Esodes::WITHOUT_EXAMINATIONS.map {|p| Esodes::esod_matter_iks_name(p) }.join(', ') + '"', size: 11, :align => :left
      display_exams_without_examinations_table

      #move_down 15
      #text 'Według rodzaju wniosku', size: 12, :align => :left
      #display_exams_with_examinations_table
    end

    repeat(:all, :dynamic => true) do
      logo
      title(category, date_start, date_end)
      footer
      text "Strona #{page_number} / #{page_count}", size: 7, :align => :left, :valign => :bottom  
    end

  end

  def display_exams_with_examinations_table
    #bounding_box([0, 687], :width => 525, :height => 678) do 
      if table_exams_with_examinations_data.empty?
        text "- brak danych -"
      else
        table( table_exams_with_examinations_data,
              :header => 1,   # True or 1... ilość wierszy jako nagłowek
              #:column_widths => [85, 62, 378], # 525 portrait, 770 landscape
              #:column_widths => [84, 62, 624], # 525 portrait, 770 landscape
              :column_widths => [84, 441], # 525 portrait, 770 landscape
              :row_colors => ["ffffcc", "e6ffcc"],
              :cell_style => { size: 9, :border_width => 0.5, :inline_format => true }
            ) do
          #columns(0).align = :right / :center
          columns(0).align = :left
          columns(0).size = 7
          columns(1).align = :left
          columns(1).size = 7
          #row(0).font_style = :bold 
          row(0).size = 9 
          row(0).background_color = "C0C0C0"
          row(0).columns(1).align = :left
          row(0).columns(1).size = 7
          row(0).columns(2).align = :left
          row(0).columns(2).size = 7
          #row(0).columns(2).valign = :top
          #row(0).columns(2).align = :left
        end             
      end
      display_total_table_exams_with_examinations
    #end  
  end

  def table_exams_with_examinations_data
    table_data ||= [
                    ["Sesja",
                     "Typ świadectwa / Ilość wniosków / Rodzaj wniosku / Wynik (* Pozytywny => Świadectwo)"]
                    ] + 
                     @exams.map { |p| [ 
                        "#{p.number} \n #{p.date_exam} \n #{p.place_exam}",
                        division_sub(p)
                      ] } + 
                    [ ["","<b><i><color rgb='e60000'>zestawienie sumaryczne:</color></i></b>"], 
                     [  "<b><i><color rgb='e60000'>łącznie:  #{@exams.size}</color></i></b>", 
                        division_sub(@exams) #sum_division_sub(@exams)
                     ]
                    ]

  end


  def display_exams_without_examinations_table
    #bounding_box([0, 687], :width => 525, :height => 678) do 
      if table_exams_without_examinations_data.empty?
        text "- brak danych -"
      else
        table( table_exams_without_examinations_data,
              :header => 1,   # True or 1... ilość wierszy jako nagłowek
              #:column_widths => [85, 62, 378], # 525 portrait, 770 landscape
              #:column_widths => [84, 62, 624], # 525 portrait, 770 landscape
              :column_widths => [84, 441], # 525 portrait, 770 landscape
              :row_colors => ["ffffcc", "e6ffcc"],
              :cell_style => { size: 9, :border_width => 0.5, :inline_format => true }
            ) do
          #columns(0).align = :right / :center
          columns(0).align = :left
          columns(0).size = 7
          columns(1).align = :left
          columns(1).size = 7
          #row(0).font_style = :bold 
          row(0).size = 9 
          row(0).background_color = "C0C0C0"
          row(0).columns(1).align = :left
          row(0).columns(1).size = 7
          row(0).columns(2).align = :left
          row(0).columns(2).size = 7
          #row(0).columns(2).valign = :top
          #row(0).columns(2).align = :left
        end             
      end
      display_total_table_exams_with_examinations
    #end  
  end

  def table_exams_without_examinations_data
    table_data ||= [
                    ["Sesja",
                     "Typ świadectwa / Ilość wniosków / Rodzaj wniosku / Wydane świadectwa"]
                    ] + 
                     @exams_without_examinations.map { |p| [ 
                        "#{p.number} \n #{p.date_exam}",
                        without_examinations_division_sub(p)
                      ] } + 
                    [ ["","<b><i><color rgb='e60000'>zestawienie sumaryczne:</color></i></b>"],
                     [  "<b><i><color rgb='e60000'>łącznie:  #{@exams_without_examinations.size}</color></i></b>", 
                        without_examinations_division_sub(@exams_without_examinations) #sum_division_sub(@exams)
                     ]
                    ]

  end


  def division_sub(exam_for_sub)
    sub_data = sub_division_rows(exam_for_sub)
    make_table(sub_data, :cell_style => { :border_width => 0.5, :inline_format => true }) do
      # suma width = 624
      #row(0).background_color = "e6e6e6"
      #row(0).size = 5 
      columns(0).width = 40
      columns(0).size = 7
      columns(1).align = :right
      columns(1).width = 27
      columns(1).size = 7
      columns(2).width = 214
      columns(2).size = 7
      columns(3).width = 160
      columns(3).size = 7
    end   
  end

  def sub_division_rows(exam_for_sub)
    res = []
    examinations = Examination.where(exam: exam_for_sub)
    Division.where(id: examinations.map(&:division_id).uniq).order(:short_name).map do |sub_item|
      res.push([ "#{sub_item.short_name}", 
                 "#{Examination.where(exam: exam_for_sub, division: sub_item).size}", 
                 esod_category_sub(exam_for_sub, sub_item),
                 examination_result_sub(exam_for_sub, sub_item)
                ]) 
    end  
    res.push([  "<i>razem:</i>", 
                "<i>#{Examination.where(exam: exam_for_sub).size}</i>", 
                "",
                "<i>'Pozytywny' razem: #{Examination.where(exam: exam_for_sub, examination_result: 'P').size}</i>"
              ])
  end

  def without_examinations_division_sub(exam_for_sub)
    sub_data = sub_without_examinations_division_rows(exam_for_sub)
    make_table(sub_data, :cell_style => { :border_width => 0.5, :inline_format => true }) do
      # suma width = 624
      #row(0).background_color = "e6e6e6"
      #row(0).size = 5 
      columns(0).width = 40
      columns(0).size = 7
      columns(1).align = :right
      columns(1).width = 27
      columns(1).size = 7
      columns(2).width = 374
      columns(2).size = 7
    end   
  end

  def sub_without_examinations_division_rows(exam_for_sub)
    res = []
    certificates = Certificate.where(exam: exam_for_sub)
    Division.where(id: certificates.map(&:division_id).uniq).order(:short_name).map do |sub_item|
      res.push([ "#{sub_item.short_name}", 
                 "#{Certificate.where(exam: exam_for_sub, division: sub_item).size}", 
                 without_examinations_esod_category_sub(exam_for_sub, sub_item)
                ]) 
    end  
    res.push([  "<i>razem:</i>", 
                "<i>#{Certificate.where(exam: exam_for_sub).size}</i>", 
                ""
              ])
  end

  def esod_category_sub(exam_for_sub, division_for_sub)
    sub_data = sub_esod_category_rows(exam_for_sub, division_for_sub)
    #make_table(sub_data, :cell_style => { :border_width => 0.5, :background_color => "e6ffcc", :inline_format => true }) do
    make_table(sub_data, :cell_style => { :border_width => 0.5, :inline_format => true }) do
      columns(0).width = 187
      columns(0).size = 7
      columns(1).align = :right
      columns(1).width = 27
      columns(1).size = 7
    end   
  end

  def sub_esod_category_rows(exam_for_sub, division_for_sub)
    examinations = Examination.where(exam: exam_for_sub, division: division_for_sub)
    examinations.map(&:esod_category).uniq.sort_by {|a| "#{a}"}.map do |sub_item|
      [ 
        Esodes::esod_matter_iks_name(sub_item), 
        "#{Examination.where(exam: exam_for_sub, division: division_for_sub, esod_category: sub_item).size}"
      ]
    end
  end

  def without_examinations_esod_category_sub(exam_for_sub, division_for_sub)
    sub_data = sub_without_examinations_esod_category_rows(exam_for_sub, division_for_sub)
    #make_table(sub_data, :cell_style => { :border_width => 0.5, :background_color => "e6ffcc", :inline_format => true }) do
    make_table(sub_data, :cell_style => { :border_width => 0.5, :inline_format => true }) do
      columns(0).width = 347
      columns(0).size = 7
      columns(1).align = :right
      columns(1).width = 27
      columns(1).size = 7
    end   
  end

  def sub_without_examinations_esod_category_rows(exam_for_sub, division_for_sub)
    certificates = Certificate.where(exam: exam_for_sub, division: division_for_sub)
    certificates.map(&:esod_category).uniq.sort_by {|a| "#{a}"}.map do |sub_item|
      [ 
        Esodes::esod_matter_iks_name(sub_item), 
        "#{Certificate.where(exam: exam_for_sub, division: division_for_sub, esod_category: sub_item).size}"
      ]
    end
  end

  def examination_result_sub(exam_for_sub, division_for_sub)
    sub_data = sub_examination_result_rows(exam_for_sub, division_for_sub)
    #make_table(sub_data, :cell_style => { :border_width => 0.5, :background_color => "FFFFCC", :inline_format => true }) do
    make_table(sub_data, :cell_style => { :border_width => 0.5, :inline_format => true }) do
      columns(0).width = 133
      columns(0).size = 7
      columns(1).align = :right
      columns(1).width = 27
      columns(1).size = 7
    end   
  end

  def sub_examination_result_rows(exam_for_sub, division_for_sub)
    #res = []
    examinations = Examination.where(exam: exam_for_sub, division: division_for_sub)
    examinations.map(&:examination_result).uniq.sort_by {|a| "#{a}"}.map do |sub_item|
       [ 
                  examination_result_name(sub_item), 
                  "#{Examination.where(exam: exam_for_sub, division: division_for_sub, examination_result: sub_item).size}"
                ]
    end
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

  def examination_result_name(p)
    case p
    when 'B'
      'Negatywny bez prawa do poprawki'
    when 'N'
      'Negatywny z prawem do poprawki'
    when 'O'
      'Nieobecny'
    when 'P'
      'Pozytywny'
    when 'Z'
      'Zmiana terminu'
    when '', nil
      ''
    else
      'Error !'
    end  
  end

  def display_total_table_exams_with_examinations
    #move_down 5    
    #stroke_line [350, cursor], [525,cursor], self.line_width = 2
    #move_down 5    
    #text_box "Razem:",                                                                        :at => [302, cursor], :width => 40, :height => 12, size: 9, :align => :right  
  end


  def logo
    #logopath =  "#{Rails.root}/app/assets/images/pop_logo.png"
    #image logopath, :width => 197, :height => 91
    #image "#{Rails.root}/app/assets/images/uke_logo.png", :at => [430, 760]
    image "#{Rails.root}/app/assets/images/logo_big.png", :height => 50
    #image "#{Rails.root}/app/assets/images/orzel.jpg", :height => 50, :position => :center
  end


  def title(cat, d_start, d_end)
    move_up 30
     text "Statystyki sesji #{category_name(cat.upcase)} za okres: #{d_start} -:- #{d_end}", size: 13, :align => :right
  end

  def footer
    # stroke_line [0, 10], [525,10], self.line_width = 0.1
    stroke_line [0, 10], [770,10], self.line_width = 0.1
    text "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE-BI-WUSA (B&J) 2015", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

end
