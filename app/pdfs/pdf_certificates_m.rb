class PdfCertificatesM < Prawn::Document

  def initialize(certificates, view, author, title)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # super(:page_size => [105mm, 150mm], :page_layout => :portrait)
    # wiec komentuje super() i ...
  # super(:page_size => [105mm, 150mm], :page_layout => :landscape)
    super(:page_size => [297, 425], 
          :page_layout => :portrait,
          :info => {
                      :Title        => title,
                      :Author       => author,
                      :Subject      => "",
                      :CreationDate => Time.now,
                    }
          )
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
    str_name = "#{certificate.customer.given_names} #{certificate.customer.name.mb_chars.upcase}"
    #text_box "#{str_name}",                                           :at => [  0, 356], :width => 230, :height => 12, size: 12, :align => :center, :style => :bold


    if str_name.length <= 30 
      text_box "#{str_name}",                                         :at => [  0, 356], :width => 230, :height => 12, size: 12, :align => :center, :style => :bold
    elsif str_name.length <= 34
      text_box "#{str_name}",                                         :at => [  0, 356], :width => 230, :height => 11, size: 10, :align => :center, :style => :bold
    else
      text_box "#{str_name}",                                         :at => [  0, 356], :width => 230, :height => 11, size:  9, :align => :center, :style => :bold
    end



    text_box "#{certificate.customer.birth_date_and_place}",          :at => [   0, 327], :width => 230, :height => 10, size: 10, :align => :center
 
    text_box "#{certificate.user.department.address_city} #{certificate.date_of_issue.strftime('%d.%m.%Y')}", :at => [  0, 164], :width => 230, :height => 10, size: 10, :align => :center

    if certificate.valid_thru.present?
      text_box "#{certificate.valid_thru.strftime('%d.%m.%Y')}",      :at => [ 184, 128], :width => 70, :height => 10, size: 9, :align => :left, :style => :bold
    end

    text_box "#{certificate.number}",                                 :at => [ 167,   -2], :width => 80, :height => 11, size: 11, :align => :left, :style => :bold

  end


end
