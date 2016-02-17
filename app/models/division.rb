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
#  add_index "divisions", ["short"], name: "index_divisions_on_short", unique: true, using: :btree
#
class Division < ActiveRecord::Base
  has_many :certificates  
  has_many :subjects, dependent: :destroy  

  accepts_nested_attributes_for :subjects

  # validates
  validates :name, presence: true, uniqueness: { :case_sensitive => false, :scope => [:category] }
  validates :category, presence: true, inclusion: { in: %w(L M R) }
  validates :short_name, presence: true
  validates :number_prefix, presence: true


  # scopes
  scope :only_category_scope, ->(cat)  { where(category: cat.upcase) }
  scope :by_name, -> { order(:name) }

end
