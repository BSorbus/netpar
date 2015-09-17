class Department < ActiveRecord::Base
  has_many :users

  has_many :works, as: :trackable



  # validates
  validates :short, presence: true,
                    length: { in: 1..15 },
                    uniqueness: { case_sensitive: false }
  validates :name, presence: true,
                    length: { in: 1..100 },
                    uniqueness: { case_sensitive: false }
  validates :address_city, presence: true,
                    length: { in: 1..50 }


  # scopes
	scope :by_short, -> { order(:short) }
	scope :by_name, -> { order(:name) }

	before_save { self.short = short.upcase }

  def fullname_and_id
    "#{name} (#{id})"
  end

  def address_street_and_house_and_number
    res = "#{address_street}"
    res +=  " #{address_house}" if address_house.present?
    res +=  "/#{address_number}" if address_number.present?
    res
  end


end
