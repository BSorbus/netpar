# Represents the roles that define the permissions
#  create_table "roles", force: :cascade do |t|
#    t.string   "name"
#    t.string   "activities", default: [], array: true
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
#  create_table "roles_users", id: false, force: :cascade do |t|
#    t.integer  "role_id"
#    t.integer  "user_id"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
#  add_index "roles_users", ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", unique: true, using: :btree
#  add_index "roles_users", ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", unique: true, using: :btree
#
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  has_many :works, as: :trackable


  # validates
  validates :name, presence: true,
                    length: { in: 1..100 },
                    :uniqueness => { :case_sensitive => false }


  # scopes
  scope :by_name, -> { order(:name) }


  def fullname_and_id
    "#{name} (#{id})"
  end

  def users_used
    #@users_used ||= self.users.order(:name)
    @users_used ||= self.users.by_name
  end

  def users_not_used
    @users_not_used ||= User.where.not(id: users_used.map(&:id)).by_name
  end

  
end
