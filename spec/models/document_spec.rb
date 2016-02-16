# Represents attached files
#  create_table "documents", force: :cascade do |t|
#    t.string   "fileattach_id"
#    t.string   "fileattach_filename"
#    t.string   "fileattach_content_type"
#    t.integer  "fileattach_size"
#    t.integer  "documentable_id"
#    t.string   "documentable_type"
#    t.datetime "created_at",              null: false
#    t.datetime "updated_at",              null: false
#  end
#  add_index "documents", ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id", using: :btree
#
require 'rails_helper'

RSpec.describe Document, type: :model do
  let(:document) { FactoryGirl.build :document }
  subject { document }

  it { should respond_to(:fileattach_filename) }
  it { should respond_to(:fileattach_content_type) }
  it { should respond_to(:fileattach_size) }
  it { should respond_to(:documentable_id) }
  it { should respond_to(:documentable_type) }

  it { should belong_to :documentable }

  it { should have_many(:works) }


end
