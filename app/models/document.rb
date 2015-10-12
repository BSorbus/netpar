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
class Document < ActiveRecord::Base
  belongs_to :documentable, polymorphic: true

  attachment :fileattach

  has_many :works, as: :trackable

  validates :fileattach, presence: true
  validates_numericality_of :fileattach_size, less_than: 10.megabytes.to_i 
  #validates :fileattach_filename, presence: true

  def fullname_and_id
    "#{fileattach_filename} (#{id})"
  end

end
