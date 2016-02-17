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

  it { should validate_presence_of(:number) }
  it { should validate_length_of(:number).is_at_least(1).is_at_most(30) }
  it { should validate_uniqueness_of(:number).scoped_to(:category).case_insensitive }
#  it { should validate_presence_of :date_of_issue }
  it { should validate_presence_of(:division) }
  it { should validate_presence_of(:customer) }
  it { should validate_presence_of(:exam) }
  it { should validate_presence_of(:user) }

  it { should validate_presence_of(:category) }
  it { should validate_inclusion_of(:category).in_array(['L', 'M', 'R']) }
  #it { should validate_inclusion_of(:category).in_array(%w(L M R)) }


  it { should belong_to :division }
  it { should belong_to :exam }
  it { should belong_to :customer }
  it { should belong_to :user }

  it { should have_one(:examination) }

  it { should have_many(:works) }
  it { should have_many(:documents) }


  describe '#with trait :lot' do
    before(:each) { @certificate = FactoryGirl.build :certificate, :lot }
    subject { @certificate }

    #let(:certificate_lot) { @certificate = FactoryGirl.build :certificate, :lot }
    #subject { certificate_lot }

    it { should respond_to(:number) }
    it { should respond_to(:date_of_issue) }
    it { should respond_to(:certificate_status) }
    it { should respond_to(:division_id) }
    it { should respond_to(:exam_id) }
    it { should respond_to(:customer_id) }
    it { should respond_to(:note) }
    it { should respond_to(:category) }
    it { should respond_to(:user_id) }

    it "#category returns 'L'" do
      expect(@certificate.category).to match 'L'
    end
  end  

  describe '#with trait :mor' do
    before(:each) { @certificate = FactoryGirl.build :certificate, :mor }
    subject { @certificate }
    #let(:certificate_mor) { @certificate = FactoryGirl.build :certificate, :mor }
    #subject { certificate_mor }

    it { should respond_to(:number) }
    it { should respond_to(:date_of_issue) }
    it { should respond_to(:certificate_status) }
    it { should respond_to(:division_id) }
    it { should respond_to(:exam_id) }
    it { should respond_to(:customer_id) }
    it { should respond_to(:note) }
    it { should respond_to(:category) }
    it { should respond_to(:user_id) }

    it "#category returns 'M'" do
      expect(@certificate.category).to match 'M'
    end
  end  

  describe '#with trait :ra' do
    before(:each) { @certificate = FactoryGirl.build :certificate, :ra }
    subject { @certificate }
    #let(:certificate_ra) { @certificate = FactoryGirl.build :certificate, :ra }
    #subject { certificate_ra }

    it { should respond_to(:number) }
    it { should respond_to(:date_of_issue) }
    it { should respond_to(:certificate_status) }
    it { should respond_to(:division_id) }
    it { should respond_to(:exam_id) }
    it { should respond_to(:customer_id) }
    it { should respond_to(:note) }
    it { should respond_to(:category) }
    it { should respond_to(:user_id) }

    it "#category returns 'R'" do
      expect(@certificate.category).to match 'R'
    end

  end  

#  it "does not allow NUMBER and DOING_BUSINESS_AS to be the same" do
#    certificate = build(:certificate, number: "same-name", number: "same-name")
#    expect(certificate).to be_invalid
#  end

end

