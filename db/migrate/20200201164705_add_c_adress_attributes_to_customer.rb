class AddCAdressAttributesToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :c_lives_in_poland, :boolean
    add_column :customers, :c_address_id, :integer
    add_column :customers, :c_teryt_code, :string,                limit: 20, default: ""
    add_column :customers, :c_province_code, :string,             limit: 20, default: ""
    add_column :customers, :c_province_name, :string,             limit: 50, default: ""
    add_column :customers, :c_district_code, :string,             limit: 20, default: ""
    add_column :customers, :c_district_name, :string,             limit: 50, default: ""
    add_column :customers, :c_commune_code, :string,              limit: 20, default: ""
    add_column :customers, :c_commune_name, :string,              limit: 50, default: ""
    add_column :customers, :c_city_code, :string,              	  limit: 20, default: ""
    add_column :customers, :c_city_name, :string,                 limit: 50, default: ""
    add_column :customers, :c_city_parent_code, :string,          limit: 20, default: ""
    add_column :customers, :c_city_parent_name, :string,          limit: 50, default: ""
    add_column :customers, :c_street_code, :string,               limit: 20, default: ""
    add_column :customers, :c_street_name, :string,               limit: 50, default: ""
    add_column :customers, :c_street_attribute, :string,          limit: 20, default: ""
    add_column :customers, :c_post_code, :string,                 limit: 20, default: ""
    add_column :customers, :c_post_code_numbers, :string,         limit: 100, default: ""
  end
end
