#  create_table "citizenships", force: :cascade do |t|
#    t.string   "name"
#    t.string   "short"
#    t.datetime "created_at", null: false
#    t.datetime "updated_at", null: false
#  end
#  add_index "citizenships", ["name"], name: "index_citizenships_on_name", unique: true, using: :btree

require 'rails_helper'

RSpec.describe Citizenship, type: :model do
  let(:citizenship) { FactoryGirl.build :citizenship }
  subject { citizenship }

  it { should respond_to(:name) }
  it { should respond_to(:short) }


  it { should have_many(:customers) }
 
end
