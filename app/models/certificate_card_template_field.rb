# Pole nadruku na karcie plastikowej: atrybut świadectwa, strona karty, obszar w mm (od lewego górnego rogu karty
# 85,6 × 54 mm) i czcionka. Tekst dopasowuje się do obszaru (zmniejsza się, gdy jest za długi), zdjęcie wpisuje się
# w obszar z zachowaniem proporcji.
class CertificateCardTemplateField < ActiveRecord::Base
  CARD_WIDTH = 85.6
  CARD_HEIGHT = 54.0
  SIDES = %w(front back)
  ALIGNS = %w(left center right)
  # Atrybuty do nadruku (wartości – CertificateCardData), w kolejności listy w edytorze układu.
  ATTRIBUTES = %w(full_name birth_date birth_place birth_date_and_place number date_of_issue place_of_issue
                  place_and_date_of_issue valid_thru division_card_text photo)
  IMAGE_ATTRIBUTES = %w(photo)

  belongs_to :template, class_name: 'CertificateCardTemplate', foreign_key: :certificate_card_template_id, inverse_of: :fields

  # Pole zaznaczone w edytorze („ptaszek”) – niezaznaczone nie jest zapisywane albo jest usuwane.
  attr_writer :enabled

  validates :attribute_name, inclusion: { in: ATTRIBUTES }, uniqueness: { scope: :certificate_card_template_id }
  validates :side, inclusion: { in: SIDES }
  validates :align, inclusion: { in: ALIGNS }
  validates :color, format: { with: /\A[0-9A-Fa-f]{6}\z/ }
  validates :x, :width, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: CARD_WIDTH }
  validates :y, :height, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: CARD_HEIGHT }
  validates :width, :height, numericality: { greater_than: 0 }
  validates :font_size, numericality: { greater_than_or_equal_to: 4, less_than_or_equal_to: 40 }
  validate :inside_card

  def enabled
    @enabled.nil? ? persisted? : @enabled
  end

  def image?
    IMAGE_ATTRIBUTES.include?(attribute_name)
  end

  def label
    I18n.t(attribute_name, scope: 'pages.certificate_card_template.attributes')
  end

  private

    def inside_card
      return if [x, y, width, height].any?(&:nil?)
      errors.add(:width, I18n.t('activerecord.errors.certificate_card_template.field_outside', label: label)) if x + width > CARD_WIDTH + 0.001
      errors.add(:height, I18n.t('activerecord.errors.certificate_card_template.field_outside', label: label)) if y + height > CARD_HEIGHT + 0.001
    end
end
