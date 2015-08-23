class Department < ActiveRecord::Base
  has_many :users

  validates :short, presence: true,
                    length: { in: 1..10 },
                    uniqueness: { case_sensitive: false }
  validates :name, presence: true,
                    length: { in: 1..100 },
                    uniqueness: { case_sensitive: false }
  validates :address_city, presence: true,
                    length: { in: 1..50 }


	scope :by_short, -> { order(:short) }
	scope :by_name, -> { order(:name) }

	before_save { self.short = short.upcase }



end
