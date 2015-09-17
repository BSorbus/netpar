class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.references :examination, index: true, foreign_key: true
      t.references :subject, index: true, foreign_key: true
      t.string :grade_result,                          limit: 1, default: ""
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :grades, [:examination_id, :subject_id],     unique: true
  end
end
