class CreateExaminers < ActiveRecord::Migration
  def change
    create_table :examiners do |t|
      t.string :name
      t.references :exam, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
