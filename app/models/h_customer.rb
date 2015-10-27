class HCustomer < ActiveRecord::Base
  belongs_to :citizenship
  belongs_to :user

end
