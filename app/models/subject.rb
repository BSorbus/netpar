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

end
