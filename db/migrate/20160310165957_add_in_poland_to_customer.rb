class AddInPolandToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :address_in_poland, :boolean, null: false, default: true
    add_column :customers, :c_address_in_poland, :boolean, null: false, default: true
  end
end
