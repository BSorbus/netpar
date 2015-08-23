class CreateDivisions < ActiveRecord::Migration
  def change
    create_table :divisions do |t|
      t.string :name
      t.string :english_name
      t.string :category,                         limit: 1, null: false, default: "R"
      t.string :short

      t.timestamps null: false
    end

    add_index :divisions, [:name, :category],     			unique: true    
    add_index :divisions, [:english_name, :category],   unique: true    
    add_index :divisions, [:short],                     unique: true    
  end
end
