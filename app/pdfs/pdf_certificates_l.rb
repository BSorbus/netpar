class PdfCertificatesL < Prawn::Document

  def initialize(certificates, view, author, title)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # super(:page_size => [105mm, 150mm], :page_layout => :portrait)
    # wiec komentuje super() i ...
  # super(:page_size => [105mm, 150mm], :page_layout => :portrait)
    super(:page_size => [297, 425], 
          :page_layout => :landscape,
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
    text_box "No. #{certificate.number}",                             :at => [  10, 245], :width => 200, :height => 14, size: 14, :align => :left, :style => :bold
    text_box "Zaświadcza się niniejszym, że",           				      :at => [ 180, 251], :width => 200, :height => 10, size:  8, :align => :left
    text_box "This is to certify that",              						      :at => [ 180, 242], :width => 200, :height => 10, size:  8, :align => :left

    str_name = "#{certificate.customer.given_names} #{certificate.customer.name}"
    if str_name.length <= 30 
      text_box "#{str_name}",  									                      :at => [ 180, 221], :width => 200, :height => 10, size: 10, :align => :center, :style => :bold
    elsif str_name.length <= 34
      text_box "#{str_name}",  									                      :at => [ 180, 221], :width => 200, :height => 10, size: 9, :align => :center, :style => :bold
    else
      text_box "#{str_name}",  									                      :at => [ 180, 221], :width => 200, :height => 10, size: 8, :align => :center, :style => :bold
    end
    text_box "." * 110,						      		                          :at => [ 180, 214], :width => 200, :height => 10, size:  5, :align => :center
    text_box "Imię i nazwisko / Name and surname",						        :at => [ 180, 209], :width => 200, :height => 10, size:  5, :align => :center

    text_box "#{certificate.customer.birth_date_and_place}",          :at => [ 180, 194], :width => 200, :height => 10, size:  9, :align => :center
    text_box "." * 110,						      		                          :at => [ 180, 188], :width => 200, :height => 10, size:  5, :align => :center
    text_box "Data i miejsce urodzenia / Date and place of birth",    :at => [ 180, 183], :width => 200, :height => 10, size:  5, :align => :center

 
    text_box "otrzymał #{certificate.division.name}",                 :at => [ 180, 170], :width => 200, :height => 28, size:  8, :align => :left, :style => :bold
    text_box "." * 130,						      		                          :at => [ 180, 145], :width => 200, :height => 10, size:  5, :align => :center
    text_box "Rodzaj świadectwa",              					              :at => [ 250, 140], :width => 200, :height => 10, size:  6, :align => :left

    text_box "has been granted #{certificate.division.english_name}", :at => [ 180, 130], :width => 200, :height => 25, size:  7, :align => :left
    text_box "." * 130,						      		                          :at => [ 180, 110], :width => 200, :height => 10, size:  5, :align => :center
    text_box "Type of Certificate",            					              :at => [ 250, 105], :width => 200, :height => 10, size:  6, :align => :left




    text_box "#{certificate.user.department.address_city} #{certificate.date_of_issue.strftime('%d.%m.%Y')}", :at => [ 180, 86], :width => 200, :height => 10, size: 9, :align => :center
    text_box "." * 110,						      		                          :at => [ 180, 80], :width => 200, :height => 10, size:  5, :align => :center
    text_box "Miejsce i data wydania / Place and date of issue of this Certificate",		                      :at => [ 180, 75], :width => 200, :height => 10, size:  5, :align => :center




    stroke_line [  5,  80], [  5,180], self.line_width = 0.1

    stroke_line [ 95,  80], [ 95,180], self.line_width = 0.1


    stroke_line [  5, 180], [ 95,180], self.line_width = 0.1

    stroke_line [  5,  80], [ 95, 80], self.line_width = 0.1


    text_box "." * 100,						      		                          :at => [   0,  10], :width => 100, :height => 10, size:  5, :align => :left
    text_box "Podpis posiadacza / Holders signature",				      	  :at => [   0,   5], :width => 100, :height => 10, size:  5, :align => :center


    text_box "." * 100,						      		                          :at => [ 265,  10], :width => 100, :height => 10, size:  5, :align => :left
    text_box "Podpis upoważnionej osoby",				      	      			  :at => [ 265,   5], :width => 100, :height => 10, size:  5, :align => :center
    text_box "Signature of duly authorized official",				      	  :at => [ 265,   0], :width => 100, :height => 10, size:  5, :align => :center


  end


end
