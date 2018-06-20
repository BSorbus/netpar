class Citizenship < ActiveRecord::Base

  has_many :customers, dependent: :nullify


  # validates
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :short, presence: true, uniqueness: { case_sensitive: false }


  # scopes
  scope :by_short, -> { order(:short) }
  scope :by_name, -> { order(:name) }

  before_save { self.short = short.upcase }

  def fullname
    "#{name} - #{short}"
  end

end
