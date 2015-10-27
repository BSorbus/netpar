# Represents Represents histories of activities
#  create_table "works", force: :cascade do |t|
#    t.integer  "trackable_id"
#    t.string   "trackable_type"
#    t.string   "trackable_url"
#    t.integer  "user_id"
#    t.string   "action"
#    t.text     "parameters"
#    t.datetime "created_at",     null: false
#    t.datetime "updated_at",     null: false
#  end
#  add_index "works", ["trackable_type", "trackable_id"], name: "index_works_on_trackable_type_and_trackable_id", using: :btree
#  add_index "works", ["user_id"], name: "index_works_on_user_id", using: :btree
#
class Work < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :user

  def action_name
    case action
    when 'create'
      'utworzył kartotekę'
    when 'update'
      'zmodyfikował kartotekę'
    when 'destroy'
      'usunął kartotekę'
    else
      'Error action value !'
    end  
  end

end
