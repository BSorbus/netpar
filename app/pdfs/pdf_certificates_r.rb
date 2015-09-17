class PdfCertificatesR < Prawn::Document

  def initialize(certificates, view, author, title)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    super(:page_size => "A5", 
          :page_layout => :portrait,
          :info => {
                      :Title        => title,
                      :Author       => author,
                      :Subject      => "",
                      :CreationDate => Time.now,
                    }
          )
    #super()

    # margin 0,5 ich ok 36 punktów
    # A4 595.28 x 841.89
    # A5 419.53 x 595.28
    # B5 498.90 x 708.66 



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
      #logo
      #title
      header_center(certificate)
      data(certificate)
      #footer
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
    text "ŚWIADECTWO RADIOAMATORSKIE", size: 16, :align => :center    
  end

  def header_center(certificate)
    text_box "#{certificate.number}",                                                             :at => [ 180, 350], :width => 219, :height => 12, size: 11, :align => :left
    text_box "#{certificate.customer.given_names} #{certificate.customer.name.mb_chars.upcase}",  :at => [   0, 320], :width => 347, :height => 12, size: 11, :align => :center
    text_box "#{certificate.customer.birth_date.strftime("%d.%m.%Y")}",                           :at => [   0, 290], :width => 347, :height => 12, size: 11, :align => :center
    text_box "#{certificate.date_of_issue.strftime("%d.%m.%Y")}",                                 :at => [   0, 260], :width => 347, :height => 12, size: 11, :align => :center
  end



  def data(certificate)
    prezes = Department.find(1)
    text_box "#{prezes.address_street_and_house_and_number}",                                     :at => [   0, 120], :width => 347, :height => 12, size: 9, :align => :center

    text_box "#{prezes.address_postal_code} #{prezes.address_city}",                              :at => [   0, 100], :width => 347, :height => 12, size: 9, :align => :center
    text_box "#{prezes.phone}",                                                                   :at => [   0, 100], :width => 150, :height => 12, size: 9, :align => :left
    text_box "#{prezes.fax}",                                                                     :at => [ 200, 100], :width => 150, :height => 12, size: 9, :align => :right

    text_box "#{certificate.user.department.phone}",                                              :at => [   0,  80], :width => 150, :height => 12, size: 9, :align => :left
    text_box "#{certificate.user.department.fax}",                                                :at => [ 200,  80], :width => 150, :height => 12, size: 9, :align => :right
  end

  def footer
    stroke_line [0, 10], [525,10], self.line_width = 0.1
    text "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE-BI-WUSA (B&J) 2015", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

end
