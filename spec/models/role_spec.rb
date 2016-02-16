#  create_table "roles", force: :cascade do |t|
#    t.string   "name"
#    t.string   "activities", default: [], array: true
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
require 'spec_helper'

RSpec.describe Role, type: :model do
  let(:role) { FactoryGirl.build :role }
  subject { role }

  it { should respond_to(:name) }
  it { should respond_to(:activities) }

  it { should have_and_belong_to_many(:users) }
  it { should have_many(:works) }

end
