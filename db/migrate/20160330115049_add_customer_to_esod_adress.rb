class AddCustomerToEsodAdress < ActiveRecord::Migration
  def change
    add_reference :esod_addresses, :customer, index: true, foreign_key: true
  end
end
