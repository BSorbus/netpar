class Individual < ActiveRecord::Base
  belongs_to :certificate
  belongs_to :customer
  belongs_to :user

  has_many :documents, as: :documentable

  validates :number, presence: true,
                    length: { in: 1..30 },
                    uniqueness: { :case_sensitive => false }
  
  validates :call_sign, presence: true,
                    length: { in: 1..20 }
  validates :call_sign, uniqueness: { :case_sensitive => false }, unless: :not_valid_status

  def not_valid_status
    license_status == 'S'
  end  
  
end
