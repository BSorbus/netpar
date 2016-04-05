#class RemoveCAddressPnaCodeRefFromCustomer < ActiveRecord::Migration
#  def change
#    remove_foreign_key :customers, column: :c_address_pna_code_id
#    remove_reference :customers, :c_address_pna_code, index: true
#  end
#end

class RemoveCAddressPnaCodeRefFromCustomer < ActiveRecord::Migration
  def up
    remove_foreign_key :customers, column: :c_address_pna_code_id
    remove_reference :customers, :c_address_pna_code, index: true
  end

  def down
    add_reference :customers, :c_address_pna_code, index: true
    add_foreign_key :customers, :pna_codes, column: :c_address_pna_code_id, primary_key: "id"
  end
end
