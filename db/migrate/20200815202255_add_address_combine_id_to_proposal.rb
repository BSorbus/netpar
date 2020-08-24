class AddAddressCombineIdToProposal < ActiveRecord::Migration
  def up
    add_column :proposals, :address_combine_id, :string, limit: 26, default: "", null: false
  end

  def down
    remove_column :proposals, :address_combine_id
  end
  
end
