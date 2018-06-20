class Subject < ActiveRecord::Base
  belongs_to :division

  has_many :grades, dependent: :nullify  

  # validates
  validates :item, presence: true,
                    numericality: true,
                    uniqueness: { case_sensitive: false, :scope => [:division_id, :esod_categories] }
  validates :name, presence: true,
                    length: { in: 1..150 },
                    uniqueness: { case_sensitive: false, :scope => [:division_id, :esod_categories] }

  validates :division, presence: true

end
