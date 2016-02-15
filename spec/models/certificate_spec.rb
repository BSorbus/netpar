#  create_table "certificates", force: :cascade do |t|
#    t.string   "number",             limit: 30, default: "",  null: false
#    t.date     "date_of_issue"
#    t.date     "valid_thru"
#    t.string   "certificate_status", limit: 1,  default: "N", null: false
#    t.integer  "division_id"
#    t.integer  "exam_id"
#    t.integer  "customer_id"
#    t.text     "note",                          default: ""
#    t.string   "category"
#    t.integer  "user_id"
#    t.datetime "created_at",                                  null: false
#    t.datetime "updated_at",                                  null: false
#  end
#  add_index "certificates", ["category"], name: "index_certificates_on_category", using: :btree
#  add_index "certificates", ["customer_id"], name: "index_certificates_on_customer_id", using: :btree
#  add_index "certificates", ["date_of_issue"], name: "index_certificates_on_date_of_issue", using: :btree
#  add_index "certificates", ["division_id"], name: "index_certificates_on_division_id", using: :btree
#  add_index "certificates", ["exam_id"], name: "index_certificates_on_exam_id", using: :btree
#  add_index "certificates", ["number", "category"], name: "index_certificates_on_number_and_category", unique: true, using: :btree
#  add_index "certificates", ["number"], name: "index_certificates_on_number", using: :btree
#  add_index "certificates", ["user_id"], name: "index_certificates_on_user_id", using: :btree

require 'rails_helper'

#RSpec.describe Certificate, type: :model do
#  pending "add some examples to (or delete) #{__FILE__}"
#end

RSpec.describe Certificate, type: :model do
  let(:certificate) { FactoryGirl.build :certificate }
  subject { certificate }

  it { should respond_to(:number) }
  it { should respond_to(:date_of_issue) }
  it { should respond_to(:certificate_status) }
  it { should respond_to(:division_id) }
  it { should respond_to(:exam_id) }
  it { should respond_to(:customer_id) }
  it { should respond_to(:note) }
  it { should respond_to(:category) }
  it { should respond_to(:user_id) }

  describe '#with trait :lot' do
    let(:certificate_lot) { FactoryGirl.build :certificate, :lot }
    subject { certificate_lot }

    it { should respond_to(:number) }
    it { should respond_to(:date_of_issue) }
    it { should respond_to(:certificate_status) }
    it { should respond_to(:division_id) }
    it { should respond_to(:exam_id) }
    it { should respond_to(:customer_id) }
    it { should respond_to(:note) }
    it { should respond_to(:category) }
    it { should respond_to(:user_id) }
  end  

  describe '#with trait :mor' do
    let(:certificate_mor) { FactoryGirl.build :certificate, :mor }
    subject { certificate_mor }

    it { should respond_to(:number) }
    it { should respond_to(:date_of_issue) }
    it { should respond_to(:certificate_status) }
    it { should respond_to(:division_id) }
    it { should respond_to(:exam_id) }
    it { should respond_to(:customer_id) }
    it { should respond_to(:note) }
    it { should respond_to(:category) }
    it { should respond_to(:user_id) }
  end  

  describe '#with trait :ra' do
    let(:certificate_ra) { FactoryGirl.build :certificate, :ra }
    subject { certificate_ra }

    it { should respond_to(:number) }
    it { should respond_to(:date_of_issue) }
    it { should respond_to(:certificate_status) }
    it { should respond_to(:division_id) }
    it { should respond_to(:exam_id) }
    it { should respond_to(:customer_id) }
    it { should respond_to(:note) }
    it { should respond_to(:category) }
    it { should respond_to(:user_id) }
  end  

end

