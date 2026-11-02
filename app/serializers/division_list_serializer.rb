# Lista typów świadectw (DataTables). Osobno od DivisionSerializer – ten jest używany także w odpowiedziach API
# i select2, więc jego zmiana zmieniłaby dane dla confirmation8 i examinations8.
class DivisionListSerializer < ActiveModel::Serializer
  attributes :id, :category, :category_fullname, :short_name, :number_prefix, :name, :english_name, :min_years_old,
             :face_image_required, :for_new_certificate, :proposal_via_internet, :enabled_in_confirmation,
             :card_template_id, :card_template_name

  # Wzór karty plastikowej obowiązujący dziś (nil – świadectwa drukowane na blankiecie papierowym).
  def card_template_id
    current_card_template && current_card_template.id
  end

  def card_template_name
    current_card_template && current_card_template.name
  end

  private

    def current_card_template
      @current_card_template ||= object.certificate_card_templates.detect(&:current?)
    end
end
