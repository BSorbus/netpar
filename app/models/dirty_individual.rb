class DirtyIndividual < ActiveRecord::Base
  belongs_to :certificate
  belongs_to :dirty_customer
  belongs_to :user
end
