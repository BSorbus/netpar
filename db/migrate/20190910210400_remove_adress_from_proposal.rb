class RemoveAdressFromProposal < ActiveRecord::Migration
  def change
    remove_column :proposals, :address_city, :string
    remove_column :proposals, :address_street, :string
    remove_column :proposals, :address_house, :string
    remove_column :proposals, :address_number, :string
    remove_column :proposals, :address_postal_code, :string
  end
end
