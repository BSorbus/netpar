require "prawn/measurement_extensions"

# Wydruk świadectw na kartach plastikowych (HID FARGO HDP6600): karta ID-1 (CR80) 85,6 × 54 mm, dla każdego świadectwa
# dwie strony – awers i rewers. Tło – grafika wzoru karty, na niej pola układu wzoru (CertificateCardTemplateField).
# items – [[CertificateCardData, CertificateCardTemplate], …].
class PdfCertificateCard < Prawn::Document
  SIZE = [CertificateCardTemplateField::CARD_WIDTH.mm, CertificateCardTemplateField::CARD_HEIGHT.mm]

  def initialize(items, author, title)
    super(page_size: SIZE, margin: 0, info: { Title: title, Author: author, Subject: '', CreationDate: Time.now })

    font_families.update("DejaVu Sans" => {
      normal: "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf",
      bold: "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
      italic: "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf",
      bold_italic: "#{Rails.root}/app/assets/fonts/DejaVuSans-BoldOblique.ttf"
    })
    font "DejaVu Sans"
    @images = {}

    items.each_with_index do |(data, template), i|
      start_new_page if i > 0
      card_side(data, template, 'front')
      start_new_page
      card_side(data, template, 'back')
    end
  end

  private

    def card_side(data, template, side)
      background = template.public_send("card_#{side}")
      image(StringIO.new(jpeg(background.id, background)), at: [0, bounds.top], width: bounds.width, height: bounds.height) if background
      template.fields.select { |field| field.side == side }.each do |field|
        field.image? ? photo_field(field, data) : text_field(field, data)
      end
    end

    def text_field(field, data)
      value = data.text(field.attribute_name)
      return if value.blank?
      fill_color field.color
      text_box value, at: [field.x.to_f.mm, bounds.top - field.y.to_f.mm], width: field.width.to_f.mm, height: field.height.to_f.mm,
                      size: field.font_size.to_f, min_font_size: 4, overflow: :shrink_to_fit, align: field.align.to_sym,
                      valign: :center, style: field.bold ? :bold : :normal
      fill_color '000000'
    end

    def photo_field(field, data)
      box = [field.x.to_f.mm, bounds.top - field.y.to_f.mm]
      bounding_box(box, width: field.width.to_f.mm, height: field.height.to_f.mm) do
        if data.photo
          image StringIO.new(jpeg("photo-#{data.photo.hash}", data.photo)), fit: [bounds.width, bounds.height], position: :center, vposition: :center
        else
          stroke_color '999999'
          stroke_bounds
          fill_color '999999'
          text_box I18n.t('pages.certificate_card_template.attributes.photo'), at: [0, bounds.top], width: bounds.width, height: bounds.height,
                   size: 6, align: :center, valign: :center
          fill_color '000000'
          stroke_color '000000'
        end
      end
    end

    # Grafika jako JPEG (bez przeplotu i przezroczystości – Prawn szybko i pewnie osadza JPEG); każda tylko raz na dokument.
    def jpeg(key, source)
      @images[key] ||= begin
        blob = source.respond_to?(:read) ? source.read : source
        image = MiniMagick::Image.read(blob)
        image.combine_options do |c|
          c.background 'white'
          c.flatten
          c.interlace 'none'
        end
        image.format 'jpg'
        image.quality 95
        image.to_blob
      end
    end
end
