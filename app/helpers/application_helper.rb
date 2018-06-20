module ApplicationHelper
  # require 'RMagick'
  # require 'refile-mini_magick'

  def form_errors_for(object=nil)
    if object.present? && object.errors.any?
      render('layouts/errors', object: object)
    end
  end

  # Adds a message to the relevant flash type array (error, notice or success) 
  #
  # @param [Symbol] flash type
  # @param [String] message
  def flash_message type, text
    flash[type] ||= []
    flash[type] << text
  end   

  # Iterates through each flash message in the array and renders it to the DOM with a partial
  #
  # @return [String] HTML elements
  def render_flash
    flash_array = []
    flash.each do |type, messages|
      if messages.is_a?(String)
        flash_array << render(partial: 'layouts/flash', format: [:html], locals: { type: type, message: messages })
      else
        unless type.to_s == 'timedout'
          messages.each do |m| 
            flash_array << render(partial: 'layouts/flash', format: [:html], locals: { type: type, message: m }) unless m.blank?
          end
        end
      end
    end
    flash_array.join('').html_safe
  end


	def get_fileattach_as_image(attach, for_service)

    case attach.fileattach_content_type
    when 'image/jpeg'
      attachment_url(attach, :fileattach, :fill, horizontal_size(for_service), vertical_size(for_service), format: "jpg", prefix: refile_app_path)
    when 'image/png'
      attachment_url(attach, :fileattach, :fill, horizontal_size(for_service), vertical_size(for_service), format: "png", prefix: refile_app_path)
    # when 'application/msword'
    #   asset_path("word.png")
    when 'application/pdf'
      # attachment_url(@attach, :fileattach, :fill, horizontal_size(for_service), vertical_size(for_service), format: "pdf")

      # pdf_file_name = @attach.fileattach_filename
      # pdf_file_name = @attach.fileattach

      # pdf_file_name = "#{Rails.root}/app/assets/images/test.pdf"
      # pdf_file = Magick::Image.read(pdf_file_name)
      # thumb = pdf_file.scale(300, 300)
      # thumb.write "#{Rails.root}/app/assets/images/test.png"


########## Działa ! ######### 
#      pdf_file_name = "#{Rails.root}/app/assets/images/test.pdf"
#      im = Magick::Image.read(pdf_file_name)
#      im[0].write(pdf_file_name + ".jpg")
#      asset_path("test.pdf.jpg")


      #pdf_file_name = attach.fileattach.read
      #pdf_file_name = attach.fileattach.read

#      pdf_file_name = "#{Rails.root}/app/assets/images/test.pdf"
#      im = Magick::Image.read(pdf_file_name)
#      im[0].write("#{Rails.root}/app/assets/images/test.jpg")
#      asset_path("test.jpg")

      asset_path("pdf.png")

      # pdf_file_name = asset_path("certificate_m.jpg")
      # pdf = Magick::ImageList.new(pdf_file_name)
      # pdf.write("home/bodzio/Documents/myimage.jpg")
    else      
      asset_path("logo.png")
    end
  end



  def get_fileattach_as_small_image(attach, for_service)

    case attach.fileattach_content_type
    when 'image/jpeg'
      attachment_url(attach, :fileattach, :fill, horizontal_small_size(for_service), vertical_small_size(for_service), format: "jpg", prefix: refile_app_path)
    when 'image/png'
      attachment_url(attach, :fileattach, :fill, horizontal_small_size(for_service), vertical_small_size(for_service), format: "png", prefix: refile_app_path)
    # when 'application/msword'
    #   asset_path("word_small.png")
    when 'application/pdf'
      #attachment_url(attach, :fileattach, :fill, horizontal_small_size(for_service), vertical_small_size(for_service), format: "pdf")

      asset_path("pdf_small.png")

    else      
      asset_path("logo.png")
    end
  end


  def horizontal_size(for_service)
    case for_service
    when 'l'
      875     
    when 'm'
      435
    when 'r'
      297 #435
    when 'e'
      435
    else
      300
    end
  end

  def vertical_size(for_service)
    case for_service
    when 'l'
      615
    when 'm'
      615
    when 'r'
      420 #615
    when 'e'
      615
    else
      300
    end
  end

  def horizontal_small_size(for_service)
    case for_service
    when 'l'
      87     
    when 'm'
      92
    when 'r'
      92
    when 'e'
      92
    when 'i'
      92
    else
      100
    end
  end

  def vertical_small_size(for_service)
    case for_service
    when 'l'
      61
    when 'm'
      128
    when 'r'
      128
    when 'e'
      128
    when 'i'
      128
    else
      100
    end
  end

end
