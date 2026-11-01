# Wzór karty plastikowej świadectwa (HID FARGO HDP6600) dla rodzaju świadectwa, wersjonowany w czasie jak stawki opłat.
# Świadectwo drukuje się wg wzoru obowiązującego w dniu jego wydania (date_of_issue) – także duplikat czy ponowny wydruk;
# bez wzoru na ten dzień – na dotychczasowym blankiecie papierowym.
# Karta ID-1 (CR80) 85,6 × 54 mm, poziomo; awers i rewers – grafika karty (PNG/JPEG), dane świadectwa nadrukowuje NETPAR.
#
# Okresy wzorów jednego rodzaju nie nakładają się. Nowy wzór „zamyka” poprzedni otwarty (bez daty „do”): dostaje on datę
# „do” = dzień przed „od” nowego i dalej służy świadectwom wydanym w swoim okresie. Wzoru nie można dodać, zmienić ani usunąć
# tak, żeby którekolwiek wydane już świadectwo zmieniło wzór (można natomiast podmienić grafikę).
class CertificateCardTemplate < ActiveRecord::Base
  IMAGE_TYPES = %w(image/png image/jpeg)
  RATIO = 85.6 / 54
  MIN_SIZE = [1011, 638] # 300 dpi; zalecane 2022 × 1276 px (600 dpi, jak drukarka)
  OPEN_END = Date.new(9999, 12, 31)

  belongs_to :division
  belongs_to :user
  has_many :works, as: :trackable
  # Układ nadruku (wersjonowany razem z grafiką wzoru).
  has_many :fields, -> { order(:id) }, class_name: 'CertificateCardTemplateField', inverse_of: :template, dependent: :delete_all
  accepts_nested_attributes_for :fields, allow_destroy: true,
                                reject_if: ->(attributes) { attributes['id'].blank? && attributes['enabled'] != '1' }

  attachment :card_front, content_type: IMAGE_TYPES
  attachment :card_back, content_type: IMAGE_TYPES

  validates :division, :name, :valid_from, :card_front, :card_back, presence: true
  validates :name, length: { maximum: 100 }
  validate :valid_from_not_after_valid_to
  validate :no_overlapping_ranges
  validate :certificates_keep_their_template
  validate :images_size

  after_create :close_previous_range
  before_destroy :ensure_no_certificates

  scope :for_date, ->(date) { where("valid_from <= ? AND (valid_to IS NULL OR valid_to >= ?)", date, date) }

  # Wzór dla świadectwa: rodzaj i dzień wydania; nil – wydruk na blankiecie papierowym.
  def self.for_certificate(certificate)
    return if certificate.date_of_issue.blank?
    where(division_id: certificate.division_id).for_date(certificate.date_of_issue).first
  end

  # Wydruk kart: [[[CertificateCardData, wzór], …], pominięte świadectwa – bez wzoru karty na dzień wydania].
  # Ten sam wzór – jeden obiekt (grafika i układ wczytywane raz na dokument).
  def self.card_items(certificates)
    templates = {}
    items = []
    skipped = []
    certificates.each do |certificate|
      found = for_certificate(certificate)
      if found
        template = templates[found.id] ||= found
        items << [CertificateCardData.from_certificate(certificate), template]
      else
        skipped << certificate
      end
    end
    [items, skipped]
  end

  # Świadectwa rodzaju wydane w podanym okresie (to – nil: bez końca).
  def self.certificates_in(division_id, from, to)
    scope = Certificate.where(division_id: division_id).where("date_of_issue >= ?", from)
    to ? scope.where("date_of_issue <= ?", to) : scope
  end

  # Świadectwa drukowane wg tego wzoru.
  def certificates
    self.class.certificates_in(division_id, valid_from, valid_to)
  end

  def period
    "#{valid_from} – #{valid_to || '…'}"
  end

  def fullname
    "#{division.category_fullname} - #{division.id_with_name_with_short} - #{name} (#{period})"
  end

  def current?
    valid_from <= Time.zone.today && (valid_to.nil? || valid_to >= Time.zone.today)
  end

  private

    # Poprzedni otwarty wzór tego rodzaju, który nowy wzór zamknie (dzień przed swoim „od”).
    def previous_open
      return unless new_record? && division_id.present? && valid_from.present?
      @previous_open ||= CertificateCardTemplate.where(division_id: division_id, valid_to: nil).where("valid_from < ?", valid_from).first
    end

    def valid_from_not_after_valid_to
      return if valid_from.blank? || valid_to.blank?
      errors.add(:valid_to, I18n.t('activerecord.errors.certificate_card_template.valid_to_before_valid_from')) if valid_to < valid_from
    end

    def no_overlapping_ranges
      return if division_id.blank? || valid_from.blank?
      others = CertificateCardTemplate.where(division_id: division_id).where.not(id: id)
      others = others.where.not(id: previous_open.id) if previous_open # zostanie zamknięty
      overlapping = others.where("valid_from <= ? AND (valid_to IS NULL OR valid_to >= ?)", valid_to || OPEN_END, valid_from)
      overlapping.each do |other|
        errors.add(:base, I18n.t('activerecord.errors.certificate_card_template.overlapping', name: other.name, period: other.period))
      end
    end

    def certificates_keep_their_template
      return if division_id.blank? || valid_from.blank?
      if new_record?
        issued = self.class.certificates_in(division_id, valid_from, valid_to)
        if issued.exists?
          errors.add(:valid_from, I18n.t('activerecord.errors.certificate_card_template.certificates_issued',
                                         count: issued.count, last: issued.maximum(:date_of_issue), next: issued.maximum(:date_of_issue) + 1.day))
        end
      elsif division_id_changed? || valid_from_changed? || valid_to_changed?
        before = self.class.certificates_in(division_id_was, valid_from_was, valid_to_was).pluck(:id).sort
        after = self.class.certificates_in(division_id, valid_from, valid_to).pluck(:id).sort
        errors.add(:base, I18n.t('activerecord.errors.certificate_card_template.certificates_change')) if before != after
      end
    end

    # Grafika karty: rozdzielczość co najmniej 300 dpi i proporcje karty 85,6 × 54 mm poziomo (tolerancja 2%).
    def images_size
      [:card_front, :card_back].each do |name|
        file = public_send(name)
        next if file.blank?
        image = MiniMagick::Image.read(file.read)
        width, height = image.width, image.height
        if width < MIN_SIZE[0] || height < MIN_SIZE[1]
          errors.add(name, I18n.t('activerecord.errors.certificate_card_template.card_too_small', size: "#{width} × #{height}"))
        elsif ((width.to_f / height) - RATIO).abs > RATIO * 0.02
          errors.add(name, I18n.t('activerecord.errors.certificate_card_template.card_wrong_ratio', size: "#{width} × #{height}"))
        end
      end
    rescue MiniMagick::Error, MiniMagick::Invalid => e
      errors.add(:base, I18n.t('activerecord.errors.certificate_card_template.card_unreadable', message: e.message))
    end

    # Zamknięcie poprzedniego otwartego wzoru (z wpisem w jego historii operacji).
    def close_previous_range
      previous = CertificateCardTemplate.where(division_id: division_id, valid_to: nil).where.not(id: id).where("valid_from < ?", valid_from).first
      return unless previous
      previous.update_column(:valid_to, valid_from - 1.day)
      previous.works.create!(trackable_url: Rails.application.routes.url_helpers.certificate_card_template_path(previous),
                             action: :update, user: user,
                             parameters: { valid_to: [nil, previous.valid_to], closed_by: { id: id, name: name } }.to_json)
    end

    def ensure_no_certificates
      return true unless certificates.exists?
      errors.add(:base, I18n.t('activerecord.errors.certificate_card_template.certificates_destroy', count: certificates.count))
      false
    end
end
