class AddAndRemoveFieldsToProposal < ActiveRecord::Migration
  def up
    remove_column :proposals, :address_id
    remove_column :proposals, :teryt_code

    add_column :proposals, :address_combine_id, :string, limit: 26, default: ""
  end

  def down
    remove_column :proposals, :address_combine_id

    add_column :proposals, :address_id, :int
    add_column :proposals, :teryt_code, :string, limit: 20, default: ""
  end
  
end
