class AddPnaToCustomer < ActiveRecord::Migration
  def change
    add_reference :customers, :address_pna_code, index: true
    add_reference :customers, :c_address_pna_code, index: true

    add_foreign_key :customers, :pna_codes, column: :address_pna_code_id, primary_key: "id"
    add_foreign_key :customers, :pna_codes, column: :c_address_pna_code_id, primary_key: "id"
  
    #add_reference :customers, :address_pna_code, index: true, foreign_key: true
    #add_reference :customers, :c_address_pna_code, index: true, foreign_key: true
  end
end
