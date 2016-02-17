#  create_table "subjects", force: :cascade do |t|
#    t.integer  "item"
#    t.string   "name"
#    t.integer  "division_id"
#    t.datetime "created_at",                  null: false
#    t.datetime "updated_at",                  null: false
#    t.boolean  "for_supplementary",      default: false, null: false
#  end
#  add_index "subjects", ["division_id"], name: "index_subjects_on_division_id", using: :btree
#
require 'rails_helper'

RSpec.describe Subject, type: :model do
  let(:my_subject) { FactoryGirl.build :subject }
  subject { my_subject }

  it { should respond_to(:item) }
  it { should respond_to(:name) }
  it { should respond_to(:division_id) }
  it { should respond_to(:for_supplementary) }

  it { should validate_presence_of(:item) }
  it { should validate_numericality_of(:item) }
  it { should validate_uniqueness_of(:item).scoped_to(:division_id, :for_supplementary).case_insensitive }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1).is_at_most(150) }
  it { should validate_uniqueness_of(:name).scoped_to(:division_id, :for_supplementary).case_insensitive }

  it { should belong_to :division }

  it { should have_many(:grades) }

end
