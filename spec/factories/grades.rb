#  create_table "grades", force: :cascade do |t|
#    t.integer  "examination_id"
#    t.integer  "subject_id"
#    t.string   "grade_result",   limit: 1, default: ""
#    t.integer  "user_id"
#    t.datetime "created_at",                            null: false
#    t.datetime "updated_at",                            null: false
#  end
#  add_index "grades", ["examination_id", "subject_id"], name: "index_grades_on_examination_id_and_subject_id", unique: true, using: :btree
#  add_index "grades", ["examination_id"], name: "index_grades_on_examination_id", using: :btree
#  add_index "grades", ["subject_id"], name: "index_grades_on_subject_id", using: :btree
#  add_index "grades", ["user_id"], name: "index_grades_on_user_id", using: :btree
#
FactoryBot.define do
  factory :grade do
    examination nil
    #subject nil
    subject 1
    grade_result ""
    user nil
  end

end
