require 'esodes'

class ExamFee < ActiveRecord::Base
  belongs_to :user
  belongs_to :division

  has_many :proposals  
  has_many :works, as: :trackable

  validates :division, presence: true

  validate :valid_from_not_after_valid_to
  validate :only_one_null_valid_from_per_category
  validate :only_one_null_valid_to_per_category
  validate :no_overlapping_ranges

  attr_accessor :category

  after_create :close_previous_range

  scope :for_date, ->(date) {
    where(
      "(valid_from IS NULL OR valid_from <= ?) AND (valid_to IS NULL OR valid_to >= ?)",
      date, date
    )
  }

  scope :current, -> { for_date(Time.zone.today) }

  def fullname
    "#{division.category_fullname} - #{division.id_name} - #{esod_category_with_name}"
  end

  def esod_category_name
    Esodes::esod_matter_iks_name(esod_category)
  end

  def esod_category_with_name
    "[#{esod_category}] #{esod_category_name}"
  end

  private

    def valid_from_not_after_valid_to
      return if valid_from.blank? || valid_to.blank?
      errors.add(:valid_from, "nie może być później niż valid_to") if valid_from > valid_to
    end

    def only_one_null_valid_from_per_category
      return unless valid_from.nil?
      existing = ExamFee.where(division_id: division_id, esod_category: esod_category, valid_from: nil)
                        .where.not(id: id)
      errors.add(:valid_from, "nie może być NULL, ponieważ istnieje już taki wpis") if existing.exists?
    end

    def only_one_null_valid_to_per_category
      return unless valid_to.nil?
      existing = ExamFee.where(division_id: division_id, esod_category: esod_category, valid_to: nil)
                        .where.not(id: id)
      errors.add(:valid_to, "nie może być NULL, ponieważ istnieje już taki wpis") if existing.exists?
    end

    def no_overlapping_ranges
      return if valid_from.blank? && valid_to.blank?

      overlapping = ExamFee
        .where(division_id: division_id, esod_category: esod_category)
        .where.not(id: id)
        .where("
          (valid_from IS NULL OR valid_from <= ?) AND
          (valid_to   IS NULL OR valid_to   >= ?)
        ", valid_to || Date.new(9999,12,31), valid_from || Date.new(0,1,1))

      errors.add(:base, "Zakres dat nakłada się na istniejący wpis") if overlapping.exists?
    end

    def close_previous_range
      return if valid_from.blank?

      previous = ExamFee
        .where(division_id: division_id, esod_category: esod_category)
        .where("id < ?", id)                 # tylko starsze rekordy
        .where(valid_to: nil)                # tylko otwarte zakresy
        .order(id: :desc)                    # najnowszy z otwartych
        .first

      return unless previous                 # brak otwartego zakresu → nic nie robimy

      new_valid_to = valid_from - 1.day

      previous.update_column(:valid_to, new_valid_to)
    end

end
