# Dictionary Division for the Certificate
#  create_table "divisions", force: :cascade do |t|
#    t.string   "name"
#    t.string   "english_name"
#    t.string   "category",      limit: 1, default: "R", null: false
#    t.datetime "created_at",                            null: false
#    t.datetime "updated_at",                            null: false
#    t.string   "short_name"
#    t.string   "number_prefix"
#  end
#  add_index "divisions", ["english_name", "category"], name: "index_divisions_on_english_name_and_category", unique: true, using: :btree
#  add_index "divisions", ["name", "category"], name: "index_divisions_on_name_and_category", unique: true, using: :btree
#
require 'rails_helper'

RSpec.describe Division, type: :model do
  let(:division) { FactoryGirl.build :division }
  subject { division }

  it { should respond_to(:name) }
  it { should respond_to(:english_name) }
  it { should respond_to(:category) }
  it { should respond_to(:short_name) }
  it { should respond_to(:number_prefix) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:category).case_insensitive }
  it { should validate_presence_of(:category) }
  it { should validate_inclusion_of(:category).in_array(['L', 'M', 'R']) }
  it { should validate_presence_of(:short_name) }
  it { should validate_presence_of(:number_prefix) }

  it { should have_many(:subjects) }
  it { should have_many(:certificates) }

  it { should accept_nested_attributes_for(:subjects) }

  describe "#subjects association" do

    before do
      division.save
      3.times { FactoryGirl.create :subject, division: division }
    end

    it "destroys the associated subjects on self destruct" do
      my_subjects = division.subjects
      division.destroy
      my_subjects.each do |my_subject|
        expect(Subject.find(my_subject)).to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

end
