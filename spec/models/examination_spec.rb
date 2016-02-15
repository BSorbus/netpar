# create_table "examinations", force: :cascade do |t|
#    t.string   "examination_category", limit: 1, default: "Z", null: false
#    t.integer  "division_id"
#    t.string   "examination_result",   limit: 1
#    t.integer  "exam_id"
#    t.integer  "customer_id"
#    t.text     "note",                           default: ""
#    t.string   "category",             limit: 1
#    t.integer  "user_id"
#    t.datetime "created_at",                                   null: false
#    t.datetime "updated_at",                                   null: false
#    t.integer  "certificate_id"
#    t.boolean  "supplementary",                  default: false, null: false
#  end
#  add_index "examinations", ["certificate_id"], name: "index_examinations_on_certificate_id", using: :btree
#  add_index "examinations", ["customer_id"], name: "index_examinations_on_customer_id", using: :btree
#  add_index "examinations", ["division_id"], name: "index_examinations_on_division_id", using: :btree
#  add_index "examinations", ["exam_id"], name: "index_examinations_on_exam_id", using: :btree
#  add_index "examinations", ["user_id"], name: "index_examinations_on_user_id", using: :btree
#
require 'rails_helper'

RSpec.describe Examination, type: :model do
  let(:examination) { FactoryGirl.build :examination }
  subject { examination }

  it { should respond_to(:examination_category) }
  it { should respond_to(:division_id) }
  it { should respond_to(:examination_result) }
  it { should respond_to(:exam_id) }
  it { should respond_to(:customer_id) }
  it { should respond_to(:note) }
  it { should respond_to(:category) }
  it { should respond_to(:user_id) }
  it { should respond_to(:certificate_id) }
  it { should respond_to(:supplementary) }

end
