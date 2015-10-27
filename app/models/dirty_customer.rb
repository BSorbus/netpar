class DirtyCustomer < ActiveRecord::Base
  belongs_to :citizenship

  has_many :dirty_certificates

end
