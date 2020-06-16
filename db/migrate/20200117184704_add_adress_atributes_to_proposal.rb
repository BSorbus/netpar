class AddAdressAtributesToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :lives_in_poland, :boolean
    add_column :proposals, :address_id, :integer
    add_column :proposals, :teryt_code, :string,                limit: 20, default: ""
    add_column :proposals, :province_code, :string,             limit: 20, default: ""
    add_column :proposals, :province_name, :string,             limit: 50, default: ""
    add_column :proposals, :district_code, :string,             limit: 20, default: ""
    add_column :proposals, :district_name, :string,             limit: 50, default: ""
    add_column :proposals, :commune_code, :string,              limit: 20, default: ""
    add_column :proposals, :commune_name, :string,              limit: 50, default: ""
    add_column :proposals, :city_code, :string,                 limit: 20, default: ""
    add_column :proposals, :city_name, :string,                 limit: 50, default: ""
    add_column :proposals, :city_parent_code, :string,          limit: 20, default: ""
    add_column :proposals, :city_parent_name, :string,          limit: 50, default: ""
    add_column :proposals, :street_code, :string,               limit: 20, default: ""
    add_column :proposals, :street_name, :string,               limit: 50, default: ""
    add_column :proposals, :street_attribute, :string,          limit: 20, default: ""
  end
end
