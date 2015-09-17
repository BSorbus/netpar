class PdfCertificatesM < Prawn::Document

  def initialize(certificates, view, author, title)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    super(:page_size => "A4", 
          :page_layout => :portrait,
          :info => {
                      :Title        => title,
                      :Author       => author,
                      :Subject      => "",
                      :CreationDate => Time.now,
                    }
          )
    #super()
    @certificates = certificates
    @view = view

    font_families.update("DejaVu Sans" => {
      :normal => "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf", 
      :bold  => "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
      :italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf",
      :bold_italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-BoldOblique.ttf"
    })
    font "DejaVu Sans", size: 11

    length_certificates = @certificates.size

    @certificates.each_with_index do |certificate, i|
      logo
      title
      header_left_corner(certificate)
      data
      footer
      start_new_page if ((i+1) < length_certificates)
    end

  end


  def logo
    #logopath =  "#{Rails.root}/app/assets/images/pop_logo.png"
    #image logopath, :width => 197, :height => 91
    #image "#{Rails.root}/app/assets/images/pop_logo.png", :at => [430, 760]
    image "#{Rails.root}/app/assets/images/orzel.jpg", :height => 50, :position => :center
  end

  def title
    #draw_text "OSWIADCZENIE UBEZPIECZONEGO", :at => [100, 475], size: 22    
    move_down 100
    text "ŚWIADECTWO MORSKIE", size: 16, :align => :center    
  end

  def header_left_corner(certificate)
    move_down 30
    #text insurance.fullname, :align => :center
    text "Numer #{certificate.number}", :style => :bold
    text "Wydane #{certificate.date_of_issue}", :style => :bold
    move_down 20
    text "Dla:", size: 10, :style => :italic
    text "#{certificate.customer.fullname_and_address}", :style => :bold
  end



  def data
    move_down 30
    text "Na podstawie, ............. tadam, tadam, tadam, tadam, .......... ............." +
         "zaświadcza się ............. tadam, tadam, tadam, tadam, ........., " +
         "itd, itd, ......."
    draw_text "." * 80, :at => [310, 300], size: 6
    draw_text "data i czytelny podpis  ", :at => [340, 290], size: 7, :style => :italic
  end

  def footer
    stroke_line [0, 10], [525,10], self.line_width = 0.1
    text "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE-BI-WUSA (B&J) 2015", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

end
