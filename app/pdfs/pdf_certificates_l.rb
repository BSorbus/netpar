class PdfCertificatesL < Prawn::Document

  def initialize(certificates, view)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # super(:page_size => [105mm, 150mm], :page_layout => :portrait)
    # wiec komentuje super() i ...
  # super(:page_size => [105mm, 150mm], :page_layout => :portrait)
    super(:page_size => [297, 425], :page_layout => :landscape)
    #super()
                        #297,637795276
                              #425,196850394
    #def mm2pt(mm)
    #    return mm*(72 / 25.4)
    #end

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
      data(certificate)
      start_new_page if ((i+1) < length_certificates)
    end

  end


  def data(certificate)
    text_box "No. #{certificate.number}",                                                                     :at => [  40, 235], :width => 200, :height => 12, size: 11, :align => :left, :style => :bold
    text_box "#{certificate.customer.given_names} #{certificate.customer.name.mb_chars.upcase}",              :at => [ 190, 210], :width => 200, :height => 12, size:  9, :align => :center, :style => :bold
    text_box "#{certificate.customer.birth_date_and_place}",                                                  :at => [ 190, 180], :width => 200, :height => 12, size:  8, :align => :center
    text_box "#{certificate.user.department.address_city} #{certificate.date_of_issue.strftime('%d.%m.%Y')}", :at => [ 190, 100], :width => 200, :height => 12, size:  8, :align => :center
  end


end
