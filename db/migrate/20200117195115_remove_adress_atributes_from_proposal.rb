class RemoveAdressAtributesFromProposal < ActiveRecord::Migration
  def change
    remove_column :proposals, :c_address_city, :string
    remove_column :proposals, :c_address_street, :string
  end
end
