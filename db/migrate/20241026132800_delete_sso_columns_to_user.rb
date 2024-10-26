class DeleteSsoColumnsToUser < ActiveRecord::Migration
  def change
    remove_column :users, :wso2is_userid, :uuid
    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
    remove_column :users, :user_name, :string
    remove_column :users, :csu_confirmed, :boolean
    remove_column :users, :csu_confirmed_at, :datetime
    remove_column :users, :csu_confirmed_by, :string
    remove_column :users, :session_index, :string
  end
end
