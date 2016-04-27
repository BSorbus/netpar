class AddCustomerToEsodContractor < ActiveRecord::Migration
  def change
    add_reference :esod_contractors, :customer, index: true, foreign_key: true
  end
end
