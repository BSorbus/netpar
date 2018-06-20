class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.integer :item
      t.string :name
      t.references :division, index: true, foreign_key: true

      t.timestamps null: false
    end
    #add_index :companies, [:name, :user_id],      unique: true
  end
end
