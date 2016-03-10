class EsodCase < ActiveRecord::Base

  # validates
  validates :nrid, presence: true,
                   numericality: true,
                   uniqueness: true
  validates :znak, presence: true,
                   uniqueness: { :case_sensitive => false }

end
