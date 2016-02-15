#  create_table "exams", force: :cascade do |t|
#    t.string   "number",     limit: 30, default: "",  null: false
#    t.date     "date_exam"
#    t.string   "place_exam", limit: 50, default: ""
#    t.string   "chairman",   limit: 50, default: ""
#    t.string   "secretary",  limit: 50, default: ""
#    t.string   "category",   limit: 1,  default: "R", null: false
#    t.text     "note",                  default: ""
#    t.integer  "user_id"
#    t.datetime "created_at",                          null: false
#    t.datetime "updated_at",                          null: false
#  end
#  add_index "exams", ["category"], name: "index_exams_on_category", using: :btree
#  add_index "exams", ["date_exam"], name: "index_exams_on_date_exam", using: :btree
#  add_index "exams", ["number", "category"], name: "index_exams_on_number_and_category", unique: true, using: :btree
#  add_index "exams", ["user_id"], name: "index_exams_on_user_id", using: :btree
#
require 'rails_helper'

RSpec.describe Exam, type: :model do
  let(:exam) { FactoryGirl.build :exam }
  subject { exam }

  it { should respond_to(:number) }
  it { should respond_to(:date_exam) }
  it { should respond_to(:place_exam) }
  it { should respond_to(:chairman) }
  it { should respond_to(:secretary) }
  it { should respond_to(:category) }
  it { should respond_to(:note) }
  it { should respond_to(:user_id) }
end
