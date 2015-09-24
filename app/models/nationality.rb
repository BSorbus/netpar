# Dictionary Nationality for the Customer
#  create_table "nationalities", force: :cascade do |t|
#    t.string   "name"
#    t.string   "short"
#    t.datetime "created_at", null: false
#    t.datetime "updated_at", null: false
#  end
#  add_index "nationalities", ["name"], name: "index_nationalities_on_name", unique: true, using: :btree

class Nationality < ActiveRecord::Base

  # scopes
  scope :by_short, -> { order(:short) }
  scope :by_name, -> { order(:name) }

  def fullname
    "#{name} - #{short}"
  end

end
