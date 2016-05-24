class CreateEsodMatterNotes < ActiveRecord::Migration
  def change
    create_table :esod_matter_notes do |t|
      t.references :esod_matter, index: true, foreign_key: true
      t.integer :sprawa, limit: 8
      t.string :tytul
      t.string :tresc

      t.timestamps null: false
    end
  end
end
