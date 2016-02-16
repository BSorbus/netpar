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
require 'rails_helper'

RSpec.describe Grade, type: :model do
  let(:grade) { FactoryGirl.build :grade }
  subject { grade }

  it { should respond_to(:examination_id) }
  it { should respond_to(:subject_id) }
  it { should respond_to(:grade_result) }
  it { should respond_to(:user_id) }

  it { should belong_to :examination }
  it { should belong_to :subject }
  it { should belong_to :user }

end
