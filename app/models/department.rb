# Represents cells of UKE
#  create_table "departments", force: :cascade do |t|
#    t.string   "short",               limit: 15,  default: "", null: false
#    t.string   "name",                limit: 100, default: "", null: false
#    t.string   "address_city",        limit: 50,  default: "", null: false
#    t.string   "address_street",      limit: 50,  default: "", null: false
#    t.string   "address_house",       limit: 10,  default: "", null: false
#    t.string   "address_number",      limit: 10,  default: ""
#    t.string   "address_postal_code", limit: 6,   default: "", null: false
#    t.string   "phone",               limit: 50,  default: ""
#    t.string   "fax",                 limit: 50,  default: ""
#    t.string   "email",               limit: 50,  default: ""
#    t.string   "director",            limit: 50,  default: ""
#    t.string   "code"
#    t.datetime "created_at",                                   null: false
#    t.datetime "updated_at",                                   null: false
#  end
#  add_index "departments", ["name"], name: "index_departments_on_name", unique: true, using: :btree
#  add_index "departments", ["short"], name: "index_departments_on_short", unique: true, using: :btree
#
class Department < ActiveRecord::Base
  has_many :users

  has_many :works, as: :trackable



  # validates
  validates :short, presence: true,
                    length: { in: 1..15 },
                    uniqueness: { case_sensitive: false }
  validates :name, presence: true,
                    length: { in: 1..100 },
                    uniqueness: { case_sensitive: false }
  validates :address_city, presence: true,
                    length: { in: 1..50 }


  # scopes
	scope :by_short, -> { order(:short) }
	scope :by_name, -> { order(:name) }

	before_save { self.short = short.upcase }

  def fullname_and_id
    "#{name} (#{id})"
  end

  def address_street_and_house_and_number
    res = "#{address_street}"
    res +=  " #{address_house}" if address_house.present?
    res +=  "/#{address_number}" if address_number.present?
    res
  end


end
