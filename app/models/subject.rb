#  create_table "subjects", force: :cascade do |t|
#    t.integer  "item"
#    t.string   "name"
#    t.integer  "division_id"
#    t.datetime "created_at",                  null: false
#    t.datetime "updated_at",                  null: false
#    t.string   "esod_categories",   default: [],                 array: true
#  end
#  add_index "subjects", ["division_id"], name: "index_subjects_on_division_id", using: :btree
#
class Subject < ActiveRecord::Base
  belongs_to :division

  has_many :grades, dependent: :nullify  

  # validates
  validates :item, presence: true,
                    numericality: true,
                    uniqueness: { case_sensitive: false, :scope => [:division_id, :esod_categories] }
  validates :name, presence: true,
                    length: { in: 1..150 },
                    uniqueness: { case_sensitive: false, :scope => [:division_id, :esod_categories] }

  validates :division, presence: true

end
