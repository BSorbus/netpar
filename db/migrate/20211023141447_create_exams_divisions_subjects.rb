class CreateExamsDivisionsSubjects < ActiveRecord::Migration
  def change
    create_table :exams_divisions_subjects do |t|
      # t.references :exams_division, index: true, foreign_key: true
      # t.references :subject, index: true, foreign_key: true
      t.references :exams_division, index: true, foreign_key: false
      t.references :subject, index: true, foreign_key: false
      t.string :testportal_test_id, null: false, default: ""

      t.timestamps null: false
    end
    add_index :exams_divisions_subjects, [:exams_division_id, :subject_id], unique: true, name: "exams_divisions_subjects_unique"
#    add_foreign_key "children", "parents", on_delete: :cascade
    add_foreign_key :exams_divisions_subjects, :exams_divisions, on_delete: :cascade


  end
end
