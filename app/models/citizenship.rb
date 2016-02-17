# Dictionary Citizenship for the Customer
#  create_table "citizenships", force: :cascade do |t|
#    t.string   "name"
#    t.string   "short"
#    t.datetime "created_at", null: false
#    t.datetime "updated_at", null: false
#  end
#  add_index "citizenships", ["name"], name: "index_citizenships_on_name", unique: true, using: :btree
#
class Citizenship < ActiveRecord::Base

  has_many :customers, dependent: :nullify


  # validates
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :short, presence: true, uniqueness: { case_sensitive: false }


  # scopes
  scope :by_short, -> { order(:short) }
  scope :by_name, -> { order(:name) }

  before_save { self.short = short.upcase }

  def fullname
    "#{name} - #{short}"
  end

end
