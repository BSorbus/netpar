require 'esodes'

class PdfExamStatistic2 < Prawn::Document

  include  ActionView::Helpers::NumberHelper

  def initialize(category, date_start, date_end, max_day, view)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    super(:page_size => "A4", :page_layout => :portrait)
    #super(:page_size => "A4", :page_layout => :landscape)
    #super()
    @exams = Exam.where(category: category.upcase, date_exam: date_start..date_end).where.not(esod_category: Esodes::WITHOUT_EXAMINATIONS).order(:date_exam, :number)
    # @exams_without_examinations = Exam.where(category: category.upcase, date_exam: date_start..date_end, esod_category: Esodes::WITHOUT_EXAMINATIONS).order(:date_exam, :number)
    @exams_without_examinations = Exam.where(category: category.upcase, date_exam: date_start..date_end).order(:date_exam, :number)
    @max_day = max_day
    @date_start = date_start
    @date_end = date_end
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
      display_exams_without_examinations_table
    end

    repeat(:all, :dynamic => true) do
      logo
      title(category, date_start, date_end, max_day)
      footer
      text "Strona #{page_number} / #{page_count}", size: 7, :align => :left, :valign => :bottom  
    end

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
                     "Data wydania / Ilość dni / ilość świadectw / Wydane świadectwa"]
                    ] + 
                     @exams_without_examinations.map { |p| [ 
                        "#{p.number} \n #{p.date_exam}",
                        certificates_date_of_issue_is_ok_sub(p)
                      ] } + 
                    [ ["","<b><i><color rgb='e60000'>zestawienie sumaryczne:</color></i></b>"],
                     [  "<b><i><color rgb='e60000'>łącznie:  #{@exams_without_examinations.size}</color></i></b>", 
                        ""    #certificates_date_of_issue_is_ok_sub(@exams_without_examinations)
                     ]
                    ]

  end

  def certificates_date_of_issue_is_ok_sub(exam_for_sub)
    sub_data = certificates_date_of_issue_is_ok_rows(exam_for_sub)
    make_table(sub_data, :cell_style => { :border_width => 0.5, :inline_format => true }) do
      # suma width = 624
      #row(0).background_color = "e6e6e6"
      #row(0).size = 5 
      columns(0).width = 70
      columns(0).size = 7

      columns(1).width = 27
      columns(1).size = 7

      columns(2).width = 27
      columns(2).size = 7

      columns(3).width = 317
      columns(3).size = 7
    end   
  end

  def certificates_date_of_issue_is_ok_rows(exam_for_sub)
    res = []
    date_end_certificate = exam_for_sub.date_exam + @max_day.to_i.days
    certificates_is_ok = Certificate.where(exam: exam_for_sub, date_of_issue: exam_for_sub.date_exam..date_end_certificate).order(:date_of_issue)
    certificates_is_not_ok = Certificate.where(exam: exam_for_sub).where('date_of_issue > ?', date_end_certificate).order(:date_of_issue)
    certificates_all_size = certificates_is_ok.size + certificates_is_not_ok.size

    certificates_is_ok.map(&:date_of_issue).uniq.map do |date_cert_sub|
      res.push([  "#{date_cert_sub}",
                  "#{(date_cert_sub - exam_for_sub.date_exam).to_int}",
                  "#{Certificate.where(exam: exam_for_sub, date_of_issue: date_cert_sub).size}",
                  "" 
                ]) 
    end  
    res.push([  "<b><color rgb='e60000'>> #{date_end_certificate}</color></b>", 
                "<b><color rgb='e60000'>> #{@max_day}</color></b>", 
                "#{Certificate.where(exam: exam_for_sub).where('date_of_issue > ?', date_end_certificate).size}",
                certificates_is_not_ok.empty? ? "" : certificates_date_of_issue_is_not_ok_sub(certificates_is_not_ok)
              ])
    res.push([  "razem:</i>",
                "", 
                "<b><color rgb='e60000'>#{certificates_all_size}</color></b>",
                "<b><color rgb='e60000'>#{certificates_is_not_ok.size} / #{certificates_all_size} = #{number_to_percentage(certificates_is_not_ok.size.to_f/certificates_all_size.to_f*100)}</color></b>" 
              ])
  end

  def certificates_date_of_issue_is_not_ok_sub(certificates)
    sub_data = certificates_date_of_issue_is_not_ok_rows(certificates)
    #make_table(sub_data, :cell_style => { :border_width => 0.5, :background_color => "e6ffcc", :inline_format => true }) do
    make_table(sub_data, :cell_style => { :border_width => 0.5, :inline_format => true }) do
      # 317
      columns(0).width = 48
      columns(0).size = 7
      columns(1).width = 52
      columns(1).size = 7
      columns(2).width = 217
      columns(2).size = 7
    end   
  end

  def certificates_date_of_issue_is_not_ok_rows(certificates)
    certificates.map do |sub_item|
      [ 
        "#{sub_item.number}", 
        "#{sub_item.date_of_issue}", 
        "#{sub_item.customer.fullname}"
      ]
    end
  end

  def certificates_sum_sub_procentage
#                "#{certificates_date_of_issue_is_not_ok.size/(certificates_date_of_issue_is_ok.size + certificates_date_of_issue_is_not_ok.size)}",
    "1.23"            
  end 

  def display_total_table_exams_with_examinations
    #move_down 5    
    #stroke_line [350, cursor], [525,cursor], self.line_width = 2
    #move_down 5    
    #text_box "Razem:",                                                                        :at => [302, cursor], :width => 40, :height => 12, size: 9, :align => :right  
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
  
  def logo
    #logopath =  "#{Rails.root}/app/assets/images/pop_logo.png"
    #image logopath, :width => 197, :height => 91
    #image "#{Rails.root}/app/assets/images/uke_logo.png", :at => [430, 760]
    image "#{Rails.root}/app/assets/images/logo_big.png", :height => 50
    #image "#{Rails.root}/app/assets/images/orzel.jpg", :height => 50, :position => :center
  end


  def title(cat, d_start, d_end, m_day)
    move_up 30
     text "Statystyki sesji #{category_name(cat.upcase)} za okres: #{d_start} -:- #{d_end} \n wskaźnik: #{m_day} (dni)", size: 12, :align => :right
  end

  def footer
    # stroke_line [0, 10], [525,10], self.line_width = 0.1
    stroke_line [0, 10], [770,10], self.line_width = 0.1
    text "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE-BI-WUSA (B&J) 2015", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

end
