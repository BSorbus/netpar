# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160309000001) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "certificates", force: :cascade do |t|
    t.string   "number",             limit: 30, default: "",  null: false
    t.date     "date_of_issue"
    t.date     "valid_thru"
    t.string   "certificate_status", limit: 1,  default: "N", null: false
    t.integer  "division_id"
    t.integer  "exam_id"
    t.integer  "customer_id"
    t.text     "note",                          default: ""
    t.string   "category",           limit: 1,  default: "R", null: false
    t.integer  "user_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "certificates", ["category"], name: "index_certificates_on_category", using: :btree
  add_index "certificates", ["customer_id"], name: "index_certificates_on_customer_id", using: :btree
  add_index "certificates", ["date_of_issue"], name: "index_certificates_on_date_of_issue", using: :btree
  add_index "certificates", ["division_id"], name: "index_certificates_on_division_id", using: :btree
  add_index "certificates", ["exam_id"], name: "index_certificates_on_exam_id", using: :btree
  add_index "certificates", ["number", "category"], name: "index_certificates_on_number_and_category", unique: true, using: :btree
  add_index "certificates", ["number"], name: "index_certificates_on_number", using: :btree
  add_index "certificates", ["user_id"], name: "index_certificates_on_user_id", using: :btree

  create_table "citizenships", force: :cascade do |t|
    t.string   "name"
    t.string   "short"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "citizenships", ["name"], name: "index_citizenships_on_name", unique: true, using: :btree

  create_table "customers", force: :cascade do |t|
    t.boolean  "human",                             default: true, null: false
    t.string   "name",                  limit: 160, default: "",   null: false
    t.string   "given_names",           limit: 50,  default: ""
    t.string   "address_city",          limit: 50,  default: ""
    t.string   "address_street",        limit: 50,  default: ""
    t.string   "address_house",         limit: 10,  default: ""
    t.string   "address_number",        limit: 10,  default: ""
    t.string   "address_postal_code",   limit: 10,  default: ""
    t.string   "address_post_office",   limit: 50,  default: ""
    t.string   "address_pobox",         limit: 10,  default: ""
    t.string   "c_address_city",        limit: 50,  default: ""
    t.string   "c_address_street",      limit: 50,  default: ""
    t.string   "c_address_house",       limit: 10,  default: ""
    t.string   "c_address_number",      limit: 10,  default: ""
    t.string   "c_address_postal_code", limit: 10,  default: ""
    t.string   "c_address_post_office", limit: 50,  default: ""
    t.string   "c_address_pobox",       limit: 10,  default: ""
    t.string   "nip",                   limit: 13,  default: ""
    t.string   "regon",                 limit: 9,   default: ""
    t.string   "pesel",                 limit: 11,  default: ""
    t.date     "birth_date"
    t.string   "birth_place",           limit: 50,  default: ""
    t.string   "fathers_name",          limit: 50,  default: ""
    t.string   "mothers_name",          limit: 50,  default: ""
    t.string   "family_name",           limit: 50,  default: ""
    t.integer  "citizenship_id",                    default: 2
    t.string   "phone",                 limit: 50,  default: ""
    t.string   "fax",                   limit: 50,  default: ""
    t.string   "email",                 limit: 50,  default: ""
    t.text     "note",                              default: ""
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["address_city"], name: "index_customers_on_address_city", using: :btree
  add_index "customers", ["address_street"], name: "index_customers_on_address_street", using: :btree
  add_index "customers", ["birth_date"], name: "index_customers_on_birth_date", using: :btree
  add_index "customers", ["citizenship_id"], name: "index_customers_on_citizenship_id", using: :btree
  add_index "customers", ["given_names"], name: "index_customers_on_given_names", using: :btree
  add_index "customers", ["name"], name: "index_customers_on_name", using: :btree
  add_index "customers", ["nip"], name: "index_customers_on_nip", using: :btree
  add_index "customers", ["pesel"], name: "index_customers_on_pesel", using: :btree
  add_index "customers", ["regon"], name: "index_customers_on_regon", using: :btree
  add_index "customers", ["user_id"], name: "index_customers_on_user_id", using: :btree

  create_table "departments", force: :cascade do |t|
    t.string   "short",               limit: 15,  default: "", null: false
    t.string   "name",                limit: 100, default: "", null: false
    t.string   "address_city",        limit: 50,  default: "", null: false
    t.string   "address_street",      limit: 50,  default: "", null: false
    t.string   "address_house",       limit: 10,  default: "", null: false
    t.string   "address_number",      limit: 10,  default: ""
    t.string   "address_postal_code", limit: 6,   default: "", null: false
    t.string   "phone",               limit: 50,  default: ""
    t.string   "fax",                 limit: 50,  default: ""
    t.string   "email",               limit: 50,  default: ""
    t.string   "director",            limit: 50,  default: ""
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "departments", ["name"], name: "index_departments_on_name", unique: true, using: :btree
  add_index "departments", ["short"], name: "index_departments_on_short", unique: true, using: :btree

  create_table "divisions", force: :cascade do |t|
    t.string   "name"
    t.string   "english_name"
    t.string   "category",      limit: 1, default: "R", null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "short_name"
    t.string   "number_prefix"
  end

  add_index "divisions", ["english_name", "category"], name: "index_divisions_on_english_name_and_category", unique: true, using: :btree
  add_index "divisions", ["name", "category"], name: "index_divisions_on_name_and_category", unique: true, using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "fileattach_id"
    t.string   "fileattach_filename"
    t.string   "fileattach_content_type"
    t.integer  "fileattach_size"
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "documents", ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id", using: :btree

  create_table "esod_cases", force: :cascade do |t|
    t.integer  "nrid"
    t.string   "znak"
    t.string   "znak_sprawy_grupujacej"
    t.string   "symbol_jrwa"
    t.string   "tytul"
    t.date     "termin_realizacji"
    t.integer  "identyfikator_kategorii_sprawy"
    t.string   "adnotacja"
    t.integer  "identyfikator_stanowiska_referenta"
    t.datetime "esod_created_at"
    t.datetime "esod_updated_et"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "esod_cases", ["nrid"], name: "index_esod_cases_on_nrid", unique: true, using: :btree
  add_index "esod_cases", ["znak"], name: "index_esod_cases_on_znak", unique: true, using: :btree

  create_table "examinations", force: :cascade do |t|
    t.string   "examination_category", limit: 1, default: "Z",   null: false
    t.integer  "division_id"
    t.string   "examination_result",   limit: 1
    t.integer  "exam_id"
    t.integer  "customer_id"
    t.text     "note",                           default: ""
    t.string   "category",             limit: 1
    t.integer  "user_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "certificate_id"
    t.boolean  "supplementary",                  default: false, null: false
  end

  add_index "examinations", ["certificate_id"], name: "index_examinations_on_certificate_id", using: :btree
  add_index "examinations", ["customer_id"], name: "index_examinations_on_customer_id", using: :btree
  add_index "examinations", ["division_id"], name: "index_examinations_on_division_id", using: :btree
  add_index "examinations", ["exam_id"], name: "index_examinations_on_exam_id", using: :btree
  add_index "examinations", ["user_id"], name: "index_examinations_on_user_id", using: :btree

  create_table "examiners", force: :cascade do |t|
    t.string   "name"
    t.integer  "exam_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "examiners", ["exam_id"], name: "index_examiners_on_exam_id", using: :btree

  create_table "exams", force: :cascade do |t|
    t.string   "number",     limit: 30, default: "",  null: false
    t.date     "date_exam"
    t.string   "place_exam", limit: 50, default: ""
    t.string   "chairman",   limit: 50, default: ""
    t.string   "secretary",  limit: 50, default: ""
    t.string   "category",   limit: 1,  default: "R", null: false
    t.text     "note",                  default: ""
    t.integer  "user_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "exams", ["category"], name: "index_exams_on_category", using: :btree
  add_index "exams", ["date_exam"], name: "index_exams_on_date_exam", using: :btree
  add_index "exams", ["number", "category"], name: "index_exams_on_number_and_category", unique: true, using: :btree
  add_index "exams", ["user_id"], name: "index_exams_on_user_id", using: :btree

  create_table "grades", force: :cascade do |t|
    t.integer  "examination_id"
    t.integer  "subject_id"
    t.string   "grade_result",   limit: 1, default: ""
    t.integer  "user_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "grades", ["examination_id", "subject_id"], name: "index_grades_on_examination_id_and_subject_id", unique: true, using: :btree
  add_index "grades", ["examination_id"], name: "index_grades_on_examination_id", using: :btree
  add_index "grades", ["subject_id"], name: "index_grades_on_subject_id", using: :btree
  add_index "grades", ["user_id"], name: "index_grades_on_user_id", using: :btree

  create_table "old_passwords", force: :cascade do |t|
    t.string   "encrypted_password",       null: false
    t.string   "password_salt"
    t.string   "password_archivable_type", null: false
    t.integer  "password_archivable_id",   null: false
    t.datetime "created_at"
  end

  add_index "old_passwords", ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable", using: :btree

  create_table "pna_codes", force: :cascade do |t|
    t.string   "pna"
    t.string   "miejscowosc"
    t.string   "ulica"
    t.string   "numery"
    t.string   "wojewodztwo"
    t.string   "powiat"
    t.string   "gmina"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "pna_codes", ["gmina"], name: "index_pna_codes_on_gmina", using: :btree
  add_index "pna_codes", ["miejscowosc", "ulica"], name: "index_pna_codes_on_miejscowosc_and_ulica", using: :btree
  add_index "pna_codes", ["miejscowosc"], name: "index_pna_codes_on_miejscowosc", using: :btree
  add_index "pna_codes", ["pna"], name: "index_pna_codes_on_pna", using: :btree
  add_index "pna_codes", ["powiat"], name: "index_pna_codes_on_powiat", using: :btree
  add_index "pna_codes", ["wojewodztwo"], name: "index_pna_codes_on_wojewodztwo", using: :btree

  create_table "refile_attachments", force: :cascade do |t|
    t.string "namespace", null: false
  end

  add_index "refile_attachments", ["namespace"], name: "index_refile_attachments_on_namespace", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "activities", default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles_users", ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", unique: true, using: :btree
  add_index "roles_users", ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", unique: true, using: :btree

  create_table "subjects", force: :cascade do |t|
    t.integer  "item"
    t.string   "name"
    t.integer  "division_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "for_supplementary", default: false, null: false
  end

  add_index "subjects", ["division_id"], name: "index_subjects_on_division_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "department_id"
    t.datetime "deleted_at"
    t.datetime "last_activity_at"
    t.datetime "expired_at"
    t.datetime "password_changed_at"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.string   "esod_encryped_password"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["department_id"], name: "index_users_on_department_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["expired_at"], name: "index_users_on_expired_at", using: :btree
  add_index "users", ["last_activity_at"], name: "index_users_on_last_activity_at", using: :btree
  add_index "users", ["password_changed_at"], name: "index_users_on_password_changed_at", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "works", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.string   "trackable_url"
    t.integer  "user_id"
    t.string   "action"
    t.text     "parameters"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "works", ["trackable_type", "trackable_id"], name: "index_works_on_trackable_type_and_trackable_id", using: :btree
  add_index "works", ["user_id"], name: "index_works_on_user_id", using: :btree

  add_foreign_key "certificates", "customers"
  add_foreign_key "certificates", "divisions"
  add_foreign_key "certificates", "exams"
  add_foreign_key "certificates", "users"
  add_foreign_key "customers", "citizenships"
  add_foreign_key "customers", "users"
  add_foreign_key "examinations", "certificates"
  add_foreign_key "examinations", "customers"
  add_foreign_key "examinations", "divisions"
  add_foreign_key "examinations", "exams"
  add_foreign_key "examinations", "users"
  add_foreign_key "examiners", "exams"
  add_foreign_key "exams", "users"
  add_foreign_key "grades", "examinations"
  add_foreign_key "grades", "subjects"
  add_foreign_key "grades", "users"
  add_foreign_key "subjects", "divisions"
  add_foreign_key "users", "departments"
end
