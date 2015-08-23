class CreateRoleUser < ActiveRecord::Migration
  def change
    create_table :roles_users, id: false do |t|
    	t.integer :role_id
    	t.integer :user_id
    	t.timestamps    	
    end
    add_index :roles_users, [:role_id, :user_id],     unique: true
    add_index :roles_users, [:user_id, :role_id],     unique: true
  end
end
