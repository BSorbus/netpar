class CostumerCodeResize < ActiveRecord::Migration
  def change
    change_column :customers, :address_postal_code, :string, :limit => 10
    change_column :customers, :c_address_postal_code, :string, :limit => 10
  end
end
