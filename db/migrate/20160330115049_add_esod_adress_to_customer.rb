class AddEsodAdressToCustomer < ActiveRecord::Migration
  def change
    add_reference :customers, :esod_address, index: true, foreign_key: true
  end
end
