class PdfUserAccountHistory < Prawn::Document

  def initialize(works, report_title, account_title_row_1, account_title_row_2, account_title_row_3, account_title_row_4, view)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    super(:page_size => "A4", :page_layout => :landscape)
    #super()
    @works = works
    @report_title = report_title
    @account_title_row_1 = account_title_row_1 
    @account_title_row_2 = account_title_row_2 
    @account_title_row_3 = account_title_row_3
    @account_title_row_4 = account_title_row_4

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
    #bounding_box([0, 640], :width => 525, :height => 618) do 
    #bounding_box([0,480], :width => 770, :height => 430) do 
    bounding_box([0, 410], :width => 770, :height => 400) do 
      if table_data.empty?
        text "No Events Found"
      else
        table( table_data,
              :header => 1,   # True or 1... ilość wierszy jako nagłowek
              :column_widths => [23, 72, 150, 135, 390],
              #:row_colors => ["ffffff", "c2ced7"],
              :cell_style => { size: 9, :border_width => 0.5 }
            ) do
          columns(0).align = :right
          columns(1).align = :left
          columns(2).align = :left
          columns(3).align = :left
          #columns(4).size = 7
          #row(0).font_style = :bold 
          row(0).size = 9 
          row(0).background_color = "C0C0C0"
          #row(0).columns(2).valign = :top
          #row(0).columns(2).align = :left
        end             
      end
    end  
  end

  def table_data
    @lp = 0
    table_data ||= [
                    ["Lp.",
                     "Data operacji",
                     "Użytkownik",
                     "Operacja",
                     "Dane"]
                    ] + 
                     @works.map { |p| [ 
                        next_lp, 
                        p.created_at.strftime("%Y-%m-%d %H:%M:%S"),
                        "#{p.user.name}" + "\n" + "#{p.user.email}",
                        p.action,
                        p.parameters
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
    image "#{Rails.root}/app/assets/images/logo_big.png", :height => 50
    #image "#{Rails.root}/app/assets/images/orzel.jpg", :height => 50, :position => :center
  end

  def header_right_corner
    move_up 50
    text "dn. #{Time.now.strftime("%Y-%m-%d %H:%M")}", size: 9, :valign => :top, :align => :right
    move_down 15
    text "#{@account_title_row_1}", size: 12, :style => :bold, :valign => :top, :align => :right
    move_down 10
    text "#{@account_title_row_2}", size: 11, :valign => :top, :align => :right
    text "#{@account_title_row_3}", size: 11, :valign => :top, :align => :right if @account_title_row_3.present?
    text "#{@account_title_row_4}", size: 11, :valign => :top, :align => :right if @account_title_row_4.present?
  end

  def title
    draw_text "#{@report_title}", :at => [30, 430], size: 13, :style => :bold
  end

  def footer
    # portrait 
    # stroke_line [0, 10], [525,10], self.line_width = 0.1
    # landscape
    stroke_line [0, 10], [770,10], self.line_width = 0.1
    text "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE-BI-WUSA (B&J) 2015", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

end
