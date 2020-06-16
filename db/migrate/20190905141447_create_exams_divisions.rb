class CreateExamsDivisions < ActiveRecord::Migration
  def change
    create_table :exams_divisions do |t|
      t.references :exam, index: true, foreign_key: true
      t.references :division, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :exams_divisions, [:exam_id, :division_id], unique: true
  end
end
