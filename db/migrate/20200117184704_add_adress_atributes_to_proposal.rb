class AddAdressAtributesToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :lives_in_poland, :boolean
    add_column :proposals, :address_id, :integer
    add_column :proposals, :teryt_code, :string
    add_column :proposals, :province_code, :string
    add_column :proposals, :province_name, :string
    add_column :proposals, :district_code, :string
    add_column :proposals, :district_name, :string
    add_column :proposals, :commune_code, :string
    add_column :proposals, :commune_name, :string
    add_column :proposals, :city_code, :string
    add_column :proposals, :city_name, :string
    add_column :proposals, :street_code, :string
    add_column :proposals, :street_name, :string
    add_column :proposals, :street_attribute, :string
  end
end
