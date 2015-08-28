class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.integer :item
      t.string :name
      t.references :division, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
