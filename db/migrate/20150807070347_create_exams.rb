class CreateExams < ActiveRecord::Migration
  def change
    create_table :exams do |t|
      t.string :number,                           limit: 30, null: false, default: ""
      t.date :date_exam
      t.string :place_exam,                       limit: 50
      t.string :chairman,                         limit: 50
      t.string :secretary,                        limit: 50
      t.string :committee_member1,                limit: 50
      t.string :committee_member2,                limit: 50
      t.string :committee_member3,                limit: 50
      t.string :category,                         limit: 1, null: false, default: "R"
      t.text :note
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :exams, [:number, :category],       unique: true
  end  
end
