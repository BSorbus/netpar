# Lista wzorów kart świadectw (DataTables): miniatury awersu i rewersu, rodzaj, nazwa, okres.
class CertificateCardTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :valid_from, :valid_to, :current, :card_front_thumb, :card_back_thumb

  has_one :division

  def valid_from
    object.valid_from.strftime("%Y-%m-%d")
  end

  def valid_to
    object.valid_to.present? ? object.valid_to.strftime("%Y-%m-%d") : ''
  end

  def current
    object.current?
  end

  def card_front_thumb
    Refile.attachment_url(object, :card_front, :fit, 172, 108, format: "jpg")
  end

  def card_back_thumb
    Refile.attachment_url(object, :card_back, :fit, 172, 108, format: "jpg")
  end
end
