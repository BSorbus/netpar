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
class Subject < ActiveRecord::Base
  belongs_to :division

  has_many :grades, dependent: :nullify  

  # validates
  validates :item, presence: true,
                    numericality: true,
                    uniqueness: { case_sensitive: false, :scope => [:division_id, :for_supplementary] }
  validates :name, presence: true,
                    length: { in: 1..150 },
                    uniqueness: { case_sensitive: false, :scope => [:division_id, :for_supplementary] }

  validates :division, presence: true

end
