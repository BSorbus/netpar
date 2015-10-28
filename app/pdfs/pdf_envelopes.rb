class PdfEnvelopes < Prawn::Document

  def initialize(customers, view)
    # New document, A4 paper, landscaped
    # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    # wiec komentuje super() i ...
    #super(:page_size => "C6", 
    #super(:page_size => [323, 459], 
    super(:page_size => "C6", 
          :page_layout => :landscape)
    # 114mm x 162mm   => 323,149606299 x 459,212598425 => 
    #super()
                        #297,637795276
                              #425,196850394
    #def mm2pt(mm)
    #    return mm*(72 / 25.4)
    #end

    # margin 0,5 ich ok 36 punktów
    # A4 595.28 x 841.89 pt = 
    # A5 419.53 x 595.28
    # B5 498.90 x 708.66 
    # C5 459.21 x 649.13 = 162mm x 229mm
    # C6 323.15 x 459.21 = 114mm x 162mm
   
    @customers = customers
    @view = view

    font_families.update("DejaVu Sans" => {
      :normal => "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf", 
      :bold  => "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
      :italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf",
      :bold_italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-BoldOblique.ttf"
    })
    font "DejaVu Sans", size: 11

    length_customers = @customers.size

    @customers.each_with_index do |customer, i|
      logo
      data(customer)
      start_new_page if ((i+1) < length_customers)
    end

  end


  def logo
    #logopath =  "#{Rails.root}/app/assets/images/pop_logo.png"
    #image logopath, :width => 197, :height => 91
    image "#{Rails.root}/app/assets/images/logo_big.jpg", :at => [0, 270], :width => 71, :height => 50
  end

  def data(customer)
    text_box "#{customer.fullname_and_address_for_envelope}", :at => [ 210, 100], :width => 200, :height => 65, size: 11, :align => :left
  end

end
