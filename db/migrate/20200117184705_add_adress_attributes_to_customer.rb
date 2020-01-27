class AddAdressAttributesToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :lives_in_poland, :boolean,          default: true
    add_column :customers, :address_id, :integer
    add_column :customers, :teryt_code, :string,                limit: 20, default: ""
    add_column :customers, :province_code, :string,             limit: 20, default: ""
    add_column :customers, :province_name, :string,             limit: 50, default: ""
    add_column :customers, :district_code, :string,             limit: 20, default: ""
    add_column :customers, :district_name, :string,             limit: 50, default: ""
    add_column :customers, :commune_code, :string,              limit: 20, default: ""
    add_column :customers, :commune_name, :string,              limit: 50, default: ""
    add_column :customers, :city_code, :string,              	limit: 20, default: ""
    add_column :customers, :city_name, :string,                 limit: 50, default: ""
    add_column :customers, :city_parent_code, :string,          limit: 20, default: ""
    add_column :customers, :city_parent_name, :string,          limit: 50, default: ""
    add_column :customers, :street_code, :string,               limit: 20, default: ""
    add_column :customers, :street_name, :string,               limit: 50, default: ""
    add_column :customers, :street_attribute, :string,          limit: 20, default: ""
  end
end
