class CreateExams < ActiveRecord::Migration
  def change
    create_table :exams do |t|
      t.string :number,                           limit: 30, null: false, default: ""
      t.date :date_exam, index: true
      t.string :place_exam,                       limit: 50, default: ""
      t.string :chairman,                         limit: 50, default: ""
      t.string :secretary,                        limit: 50, default: ""
      t.string :category,                         limit: 1, null: false, default: "R"
      t.text :note,                                         default: ""
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :exams, [:number, :category],       unique: true
  end  
end
