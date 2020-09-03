class AddAndRemoveFieldsToCustomer < ActiveRecord::Migration
  def up
    remove_column :customers, :address_in_poland
    remove_column :customers, :c_address_in_poland
    remove_column :customers, :address_id
    remove_column :customers, :c_address_id
    remove_column :customers, :teryt_code
    remove_column :customers, :c_teryt_code
    remove_column :customers, :address_teryt_pna_code_id
    remove_column :customers, :c_address_teryt_pna_code_id

    add_column :customers, :address_combine_id, :string, limit: 26, default: ""
    add_column :customers, :c_address_combine_id, :string, limit: 26, default: ""
  end

  def down
    remove_column :customers, :address_combine_id
    remove_column :customers, :c_address_combine_id

    add_column :customers, :address_in_poland, :boolean
    add_column :customers, :c_address_in_poland, :boolean
    add_column :customers, :address_id, :int
    add_column :customers, :c_address_id, :int
    add_column :customers, :teryt_code, :int
    add_column :customers, :c_teryt_code, :int
    add_column :customers, :address_teryt_pna_code_id, :int
    add_column :customers, :c_address_teryt_pna_code_id, :int
  end
  
end
