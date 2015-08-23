module ApplicationHelper
  #require 'RMagick'
  #require 'refile-mini_magick'

	def get_fileattach_as_image(attach, for_service)

    case attach.fileattach_content_type
    when 'image/jpeg'
      attachment_url(@attach, :fileattach, :fill, horizontal_size(for_service), vertical_size(for_service), format: "jpg")
    when 'application/pdf'
      attachment_url(@attach, :fileattach, :fill, horizontal_size(for_service), vertical_size(for_service), format: "pdf")

      #pdf_file_name = @attach.fileattach_filename
      #pdf_file_name = @attach.fileattach

      #pdf_file_name = "#{Rails.root}/app/assets/images/test.pdf"
      #pdf_file = Magick::Image.read(pdf_file_name)
      #thumb = pdf_file.scale(300, 300)
      #thumb.write "#{Rails.root}/app/assets/images/test.png"

      #pdf_file_name = "test.pdf[5]"
      #im = Magick::Image.read(pdf_file_name)
      #im[0].write(pdf_file_name + ".jpg")

      #pdf_file_name = asset_path("certificate_m.jpg")
      #pdf = Magick::ImageList.new(pdf_file_name)
      #pdf.write("home/bodzio/Documents/myimage.jpg")
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
      435
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
      615
    when 'e'
      615
    else
      300
    end
  end


end
