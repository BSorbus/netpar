# Represents examiners
#  create_table "examiners", force: :cascade do |t|
#    t.string   "name"
#    t.integer  "exam_id"
#    t.datetime "created_at", null: false
#    t.datetime "updated_at", null: false
#  end
#  add_index "examiners", ["exam_id"], name: "index_examiners_on_exam_id", using: :btree
#
class Examiner < ActiveRecord::Base
  belongs_to :exam

  validates :name, presence: true,
                    length: { in: 1..50 },
                    :uniqueness => { :case_sensitive => false, :scope => [:exam] }

end
