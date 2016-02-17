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


  it { should validate_presence_of(:number) }
  it { should validate_length_of(:number).is_at_least(1).is_at_most(30) }
  it { should validate_uniqueness_of(:number).scoped_to(:category).case_insensitive }
  it { should validate_presence_of(:date_exam) }
  it { should validate_presence_of(:place_exam) }
  it { should validate_length_of(:place_exam).is_at_least(1).is_at_most(50) }
  it { should validate_presence_of(:category) }
  it { should validate_inclusion_of(:category).in_array(['L', 'M', 'R']) }
  it { should validate_presence_of(:user) }



  it { should belong_to :user }

  it { should have_many(:documents) }
  it { should have_many(:works) }
  it { should have_many(:certificates) }
  it { should have_many(:examinations) }
  it { should have_many(:examiners) }

  it { should have_many(:certificate_customers) }
  it { should have_many(:examination_customers) }

  it { should accept_nested_attributes_for(:examiners) }

  describe "#examiners association" do

    before do
      exam.save
      3.times { FactoryGirl.create :examiner, exam: exam }
    end

    it "destroys the associated examiners on self destruct" do
      examiners = exam.examiners
      exam.destroy
      examiners.each do |examiner|
        expect(Subject.find(examiner)).to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

end
