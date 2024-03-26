class AddSsoColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :wso2is_userid, :uuid
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :user_name, :string
    add_column :users, :csu_confirmed, :boolean
    add_column :users, :csu_confirmed_at, :datetime
    add_column :users, :csu_confirmed_by, :string
    add_column :users, :session_index, :string
  end
end
