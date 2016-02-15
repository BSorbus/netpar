#  create_table "works", force: :cascade do |t|
#    t.integer  "trackable_id"
#    t.string   "trackable_type"
#    t.string   "trackable_url"
#    t.integer  "user_id"
#    t.string   "action"
#    t.text     "parameters"
#    t.datetime "created_at",     null: false
#    t.datetime "updated_at",     null: false
#  end
#  add_index "works", ["trackable_type", "trackable_id"], name: "index_works_on_trackable_type_and_trackable_id", using: :btree
#  add_index "works", ["user_id"], name: "index_works_on_user_id", using: :btree
#
require 'rails_helper'

RSpec.describe Work, type: :model do
  let(:work) { FactoryGirl.build :work }
  subject { work }

  it { should respond_to(:trackable_id) }
  it { should respond_to(:trackable_type) }
  it { should respond_to(:trackable_url) }
  it { should respond_to(:user_id) }
  it { should respond_to(:action) }
end
