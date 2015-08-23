class CreateDirtyAddresses < ActiveRecord::Migration
  def change
    create_table :dirty_addresses do |t|
      t.integer :code
      t.string :code_table
      t.integer :code_table_id
      t.string :address_city
      t.string :address_street
      t.string :address_house
      t.string :address_number
      t.text :note
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
