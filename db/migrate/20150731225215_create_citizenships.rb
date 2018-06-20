class CreateCitizenships < ActiveRecord::Migration
  def change
    create_table :citizenships do |t|
      t.string :name
      t.string :short

      t.timestamps null: false
    end

    add_index :citizenships, [:name],     unique: true    
  end
end
