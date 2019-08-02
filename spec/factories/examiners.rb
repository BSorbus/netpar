# Represents examiners
#  create_table "examiners", force: :cascade do |t|
#    t.string   "name"
#    t.integer  "exam_id"
#    t.datetime "created_at", null: false
#    t.datetime "updated_at", null: false
#  end
#  add_index "examiners", ["exam_id"], name: "index_examiners_on_exam_id", using: :btree
#
FactoryBot.define do
  factory :examiner do
    sequence(:name) { |n| "Examiner name #{n}" }
    #name "E name"
    exam nil
  end
end
