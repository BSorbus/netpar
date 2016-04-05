#class RemoveAddressPnaCodeRefFromCustomer < ActiveRecord::Migration
#  def change
#    remove_foreign_key :customers, column: :address_pna_code_id
#    remove_reference :customers, :address_pna_code, index: true
#  end
#end



class RemoveAddressPnaCodeRefFromCustomer < ActiveRecord::Migration
  def up
    remove_foreign_key :customers, column: :address_pna_code_id
    remove_reference :customers, :address_pna_code, index: true
  end

  def down
    add_reference :customers, :address_pna_code, index: true
    add_foreign_key :customers, :pna_codes, column: :address_pna_code_id, primary_key: "id"
  end
end


#class AddPnaToCustomer < ActiveRecord::Migration
#  def change
#    add_reference :customers, :address_pna_code, index: true
#    add_reference :customers, :c_address_pna_code, index: true

#    add_foreign_key :customers, :pna_codes, column: :address_pna_code_id, primary_key: "id"
#    add_foreign_key :customers, :pna_codes, column: :c_address_pna_code_id, primary_key: "id"
#  
#    #add_reference :customers, :address_pna_code, index: true, foreign_key: true
#    #add_reference :customers, :c_address_pna_code, index: true, foreign_key: true
#  end
#end

#Removes the foreign key on accounts.branch_id.

#remove_foreign_key :accounts, :branches
#Removes the foreign key on accounts.owner_id.

#remove_foreign_key :accounts, column: :owner_id
#Removes the foreign key named special_fk_name on the accounts table.

#remove_foreign_key :accounts, name: :special_fk_name
