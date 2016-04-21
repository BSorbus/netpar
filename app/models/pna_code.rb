class PnaCode < ActiveRecord::Base

  # validates
  validates :pna, presence: true,
                  length: { in: 6..10 }
  validates :miejscowosc, presence: true 
  validates :wojewodztwo, presence: true 
  validates :powiat, presence: true 
  validates :gmina, presence: true 

end
