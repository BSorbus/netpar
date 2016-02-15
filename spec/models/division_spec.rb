# Dictionary Division for the Certificate
#  create_table "divisions", force: :cascade do |t|
#    t.string   "name"
#    t.string   "english_name"
#    t.string   "category",      limit: 1, default: "R", null: false
#    t.string   "short"
#    t.datetime "created_at",                            null: false
#    t.datetime "updated_at",                            null: false
#    t.string   "short_name"
#    t.string   "number_prefix"
#  end
#  add_index "divisions", ["english_name", "category"], name: "index_divisions_on_english_name_and_category", unique: true, using: :btree
#  add_index "divisions", ["name", "category"], name: "index_divisions_on_name_and_category", unique: true, using: :btree
#  add_index "divisions", ["short"], name: "index_divisions_on_short", unique: true, using: :btree
#
require 'rails_helper'

RSpec.describe Division, type: :model do
  let(:division) { FactoryGirl.build :division }
  subject { division }

  it { should respond_to(:name) }
  it { should respond_to(:english_name) }
  it { should respond_to(:category) }
  it { should respond_to(:short) }
  it { should respond_to(:short_name) }
  it { should respond_to(:number_prefix) }
end
