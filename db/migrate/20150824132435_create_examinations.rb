class CreateExaminations < ActiveRecord::Migration
  def change
    create_table :examinations do |t|
      t.string :examination_category, limit: 1, null: false, default: "Z"
      t.references :division, index: true, foreign_key: true
      t.string :examination_resoult, limit: 1
      t.references :exam, index: true, foreign_key: true
      t.references :customer, index: true, foreign_key: true
      t.text :note
      t.string :category, limit: 1
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    #unique exam, user, (division?)
  end
end
