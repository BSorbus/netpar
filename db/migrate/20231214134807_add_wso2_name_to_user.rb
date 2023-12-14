class AddWso2NameToUser < ActiveRecord::Migration
  def change
    add_column :users, :wso2_name, :string
  end
end
