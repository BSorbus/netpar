class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :name
      t.string :password
      t.string :access_token

      t.timestamps null: false
    end
    add_index :api_keys, [:name], unique: true
  end
end
