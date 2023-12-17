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

ActiveRecord::Schema.define(version: 20231217163601) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "api_keys", force: :cascade do |t|
    t.string   "name"
    t.string   "password"
    t.string   "access_token"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "api_keys", ["name"], name: "index_api_keys_on_name", unique: true, using: :btree

  create_table "certificates", force: :cascade do |t|
    t.string   "number",             limit: 30, default: "",    null: false
    t.date     "date_of_issue"
    t.date     "valid_thru"
    t.string   "certificate_status", limit: 1,  default: "N",   null: false
    t.integer  "division_id"
    t.integer  "exam_id"
    t.integer  "customer_id"
    t.text     "note",                          default: ""
    t.string   "category",           limit: 1,  default: "R",   null: false
    t.integer  "user_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "canceled",                      default: false
    t.integer  "esod_category"
  end

  add_index "certificates", ["category"], name: "index_certificates_on_category", using: :btree
  add_index "certificates", ["customer_id"], name: "index_certificates_on_customer_id", using: :btree
  add_index "certificates", ["date_of_issue"], name: "index_certificates_on_date_of_issue", using: :btree
  add_index "certificates", ["division_id"], name: "index_certificates_on_division_id", using: :btree
  add_index "certificates", ["exam_id"], name: "index_certificates_on_exam_id", using: :btree
  add_index "certificates", ["number", "category"], name: "index_certificates_on_number_and_category", unique: true, using: :btree
  add_index "certificates", ["number"], name: "index_certificates_on_number", using: :btree
  add_index "certificates", ["user_id"], name: "index_certificates_on_user_id", using: :btree

  create_table "confirmation_logs", force: :cascade do |t|
    t.string   "remote_ip"
    t.text     "request_json"
    t.text     "response_json"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

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
    t.string   "phone",                 limit: 50,  default: ""
    t.string   "fax",                   limit: 50,  default: ""
    t.string   "email",                 limit: 50,  default: ""
    t.text     "note",                              default: ""
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "citizenship_code"
    t.boolean  "lives_in_poland"
    t.string   "province_code",         limit: 20,  default: ""
    t.string   "province_name",         limit: 50,  default: ""
    t.string   "district_code",         limit: 20,  default: ""
    t.string   "district_name",         limit: 50,  default: ""
    t.string   "commune_code",          limit: 20,  default: ""
    t.string   "commune_name",          limit: 50,  default: ""
    t.string   "city_code",             limit: 20,  default: ""
    t.string   "city_name",             limit: 50,  default: ""
    t.string   "city_parent_code",      limit: 20,  default: ""
    t.string   "city_parent_name",      limit: 50,  default: ""
    t.string   "street_code",           limit: 20,  default: ""
    t.string   "street_name",           limit: 50,  default: ""
    t.string   "street_attribute",      limit: 20,  default: ""
    t.string   "post_code",             limit: 20,  default: ""
    t.string   "post_code_numbers",     limit: 100, default: ""
    t.boolean  "c_lives_in_poland"
    t.string   "c_province_code",       limit: 20,  default: ""
    t.string   "c_province_name",       limit: 50,  default: ""
    t.string   "c_district_code",       limit: 20,  default: ""
    t.string   "c_district_name",       limit: 50,  default: ""
    t.string   "c_commune_code",        limit: 20,  default: ""
    t.string   "c_commune_name",        limit: 50,  default: ""
    t.string   "c_city_code",           limit: 20,  default: ""
    t.string   "c_city_name",           limit: 50,  default: ""
    t.string   "c_city_parent_code",    limit: 20,  default: ""
    t.string   "c_city_parent_name",    limit: 50,  default: ""
    t.string   "c_street_code",         limit: 20,  default: ""
    t.string   "c_street_name",         limit: 50,  default: ""
    t.string   "c_street_attribute",    limit: 20,  default: ""
    t.string   "c_post_code",           limit: 20,  default: ""
    t.string   "c_post_code_numbers",   limit: 100, default: ""
    t.string   "address_combine_id",    limit: 26,  default: ""
    t.string   "c_address_combine_id",  limit: 26,  default: ""
  end

  add_index "customers", ["address_city"], name: "index_customers_on_address_city", using: :btree
  add_index "customers", ["address_street"], name: "index_customers_on_address_street", using: :btree
  add_index "customers", ["birth_date"], name: "index_customers_on_birth_date", using: :btree
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
    t.string   "category",              limit: 1, default: "R",   null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "short_name"
    t.string   "number_prefix"
    t.integer  "min_years_old",                   default: 0
    t.boolean  "face_image_required",             default: false
    t.boolean  "for_new_certificate",             default: true,  null: false
    t.boolean  "proposal_via_internet",           default: true,  null: false
  end

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

  create_table "esod_addresses", force: :cascade do |t|
    t.integer  "nrid",                              limit: 8
    t.string   "miasto"
    t.string   "kod_pocztowy"
    t.string   "ulica"
    t.string   "numer_lokalu"
    t.string   "numer_budynku"
    t.string   "skrytka_epuap"
    t.string   "panstwo"
    t.string   "email"
    t.string   "typ"
    t.datetime "data_utworzenia"
    t.integer  "identyfikator_osoby_tworzacej"
    t.datetime "data_modyfikacji"
    t.integer  "identyfikator_osoby_modyfikujacej"
    t.boolean  "initialized_from_esod",                       default: false
    t.integer  "netpar_user"
    t.integer  "customer_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "miasto_poczty"
  end

  add_index "esod_addresses", ["customer_id"], name: "index_esod_addresses_on_customer_id", using: :btree

  create_table "esod_contractors", force: :cascade do |t|
    t.integer  "nrid",                              limit: 8
    t.string   "imie"
    t.string   "nazwisko"
    t.string   "nazwa"
    t.string   "drugie_imie"
    t.string   "tytul"
    t.string   "nip"
    t.string   "pesel"
    t.integer  "rodzaj"
    t.datetime "data_utworzenia"
    t.integer  "identyfikator_osoby_tworzacej"
    t.datetime "data_modyfikacji"
    t.integer  "identyfikator_osoby_modyfikujacej"
    t.boolean  "initialized_from_esod",                       default: false
    t.integer  "netpar_user"
    t.integer  "customer_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  add_index "esod_contractors", ["customer_id"], name: "index_esod_contractors_on_customer_id", using: :btree

  create_table "esod_incoming_letters", force: :cascade do |t|
    t.integer  "nrid",                                 limit: 8
    t.string   "numer_ewidencyjny"
    t.string   "tytul"
    t.date     "data_pisma"
    t.date     "data_nadania"
    t.date     "data_wplyniecia"
    t.string   "znak_pisma_wplywajacego"
    t.integer  "identyfikator_typu_dcmd"
    t.integer  "identyfikator_rodzaju_dokumentu"
    t.integer  "identyfikator_sposobu_przeslania"
    t.integer  "identyfikator_miejsca_przechowywania"
    t.date     "termin_na_odpowiedz"
    t.boolean  "pelna_wersja_cyfrowa"
    t.boolean  "naturalny_elektroniczny"
    t.integer  "liczba_zalacznikow"
    t.string   "uwagi"
    t.integer  "identyfikator_osoby",                  limit: 8
    t.integer  "identyfikator_adresu",                 limit: 8
    t.integer  "esod_contractor_id"
    t.integer  "esod_address_id"
    t.datetime "data_utworzenia"
    t.integer  "identyfikator_osoby_tworzacej"
    t.datetime "data_modyfikacji"
    t.integer  "identyfikator_osoby_modyfikujacej"
    t.boolean  "initialized_from_esod",                          default: false
    t.integer  "netpar_user"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.integer  "zgoda",                                          default: 1
    t.integer  "tajemnica",                                      default: 1
    t.integer  "document_id"
  end

  add_index "esod_incoming_letters", ["esod_address_id"], name: "index_esod_incoming_letters_on_esod_address_id", using: :btree
  add_index "esod_incoming_letters", ["esod_contractor_id"], name: "index_esod_incoming_letters_on_esod_contractor_id", using: :btree
  add_index "esod_incoming_letters", ["tytul"], name: "index_esod_incoming_letters_on_tytul", using: :btree

  create_table "esod_incoming_letters_documents", force: :cascade do |t|
    t.integer  "esod_incoming_letter_id"
    t.integer  "document_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "esod_incoming_letters_documents", ["esod_incoming_letter_id", "document_id"], name: "esod_incoming_letters_documents_uniq", unique: true, using: :btree

  create_table "esod_incoming_letters_matters", force: :cascade do |t|
    t.integer "esod_incoming_letter_id"
    t.integer "esod_matter_id"
    t.integer "sprawa",                  limit: 8
    t.integer "dokument",                limit: 8
    t.string  "sygnatura"
    t.boolean "initialized_from_esod",             default: false
    t.integer "netpar_user"
  end

  add_index "esod_incoming_letters_matters", ["esod_incoming_letter_id", "esod_matter_id"], name: "esod_incoming_letters_matters_incoming_letter_matter", unique: true, using: :btree
  add_index "esod_incoming_letters_matters", ["esod_incoming_letter_id"], name: "index_esod_incoming_letters_matters_on_esod_incoming_letter_id", using: :btree
  add_index "esod_incoming_letters_matters", ["esod_matter_id", "esod_incoming_letter_id"], name: "esod_incoming_letters_matters_matter_incoming_letter", unique: true, using: :btree
  add_index "esod_incoming_letters_matters", ["esod_matter_id"], name: "index_esod_incoming_letters_matters_on_esod_matter_id", using: :btree

  create_table "esod_internal_letters", force: :cascade do |t|
    t.integer  "nrid",                                         limit: 8
    t.string   "numer_ewidencyjny"
    t.string   "tytul"
    t.string   "uwagi"
    t.integer  "identyfikator_rodzaju_dokumentu_wewnetrznego"
    t.integer  "identyfikator_typu_dcmd"
    t.integer  "identyfikator_dostepnosci_dokumentu"
    t.boolean  "pelna_wersja_cyfrowa"
    t.datetime "data_utworzenia"
    t.integer  "identyfikator_osoby_tworzacej"
    t.datetime "data_modyfikacji"
    t.integer  "identyfikator_osoby_modyfikujacej"
    t.boolean  "initialized_from_esod",                                  default: false
    t.integer  "netpar_user"
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.integer  "document_id"
  end

  add_index "esod_internal_letters", ["tytul"], name: "index_esod_internal_letters_on_tytul", using: :btree

  create_table "esod_internal_letters_documents", force: :cascade do |t|
    t.integer  "esod_internal_letter_id"
    t.integer  "document_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "esod_internal_letters_documents", ["esod_internal_letter_id", "document_id"], name: "esod_internal_letters_documents_uniq", unique: true, using: :btree

  create_table "esod_internal_letters_matters", force: :cascade do |t|
    t.integer "esod_internal_letter_id"
    t.integer "esod_matter_id"
    t.integer "sprawa",                  limit: 8
    t.integer "dokument",                limit: 8
    t.string  "sygnatura"
    t.boolean "initialized_from_esod",             default: false
    t.integer "netpar_user"
  end

  add_index "esod_internal_letters_matters", ["esod_internal_letter_id", "esod_matter_id"], name: "esod_internal_letters_matters_internal_letter_matter", unique: true, using: :btree
  add_index "esod_internal_letters_matters", ["esod_internal_letter_id"], name: "index_esod_internal_letters_matters_on_esod_internal_letter_id", using: :btree
  add_index "esod_internal_letters_matters", ["esod_matter_id", "esod_internal_letter_id"], name: "esod_internal_letters_matters_matter_internal_letter", unique: true, using: :btree
  add_index "esod_internal_letters_matters", ["esod_matter_id"], name: "index_esod_internal_letters_matters_on_esod_matter_id", using: :btree

  create_table "esod_matter_notes", force: :cascade do |t|
    t.integer  "esod_matter_id"
    t.integer  "sprawa",         limit: 8
    t.string   "tytul"
    t.string   "tresc"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "esod_matter_notes", ["esod_matter_id"], name: "index_esod_matter_notes_on_esod_matter_id", using: :btree

  create_table "esod_matters", force: :cascade do |t|
    t.integer  "nrid",                               limit: 8
    t.string   "znak"
    t.string   "znak_sprawy_grupujacej"
    t.string   "symbol_jrwa"
    t.string   "tytul"
    t.date     "termin_realizacji"
    t.integer  "identyfikator_kategorii_sprawy"
    t.string   "adnotacja"
    t.integer  "identyfikator_stanowiska_referenta"
    t.boolean  "czy_otwarta",                                  default: true
    t.datetime "data_utworzenia"
    t.integer  "identyfikator_osoby_tworzacej"
    t.datetime "data_modyfikacji"
    t.integer  "identyfikator_osoby_modyfikujacej"
    t.boolean  "initialized_from_esod",                        default: false
    t.integer  "netpar_user"
    t.integer  "exam_id"
    t.integer  "examination_id"
    t.integer  "certificate_id"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
  end

  add_index "esod_matters", ["certificate_id"], name: "index_esod_matters_on_certificate_id", using: :btree
  add_index "esod_matters", ["exam_id"], name: "index_esod_matters_on_exam_id", using: :btree
  add_index "esod_matters", ["examination_id"], name: "index_esod_matters_on_examination_id", using: :btree
  add_index "esod_matters", ["identyfikator_kategorii_sprawy"], name: "index_esod_matters_on_identyfikator_kategorii_sprawy", using: :btree
  add_index "esod_matters", ["identyfikator_stanowiska_referenta"], name: "index_esod_matters_on_identyfikator_stanowiska_referenta", using: :btree
  add_index "esod_matters", ["tytul"], name: "index_esod_matters_on_tytul", using: :btree
  add_index "esod_matters", ["znak"], name: "index_esod_matters_on_znak", using: :btree

  create_table "esod_outgoing_letters", force: :cascade do |t|
    t.integer  "nrid",                                         limit: 8
    t.string   "numer_ewidencyjny"
    t.string   "tytul"
    t.integer  "wysylka"
    t.integer  "identyfikator_adresu",                         limit: 8
    t.integer  "identyfikator_sposobu_wysylki"
    t.integer  "identyfikator_rodzaju_dokumentu_wychodzacego"
    t.date     "data_wyslania"
    t.boolean  "czy_adresat_glowny",                                     default: true
    t.date     "data_pisma"
    t.integer  "numer_wersji"
    t.string   "uwagi"
    t.boolean  "zakoncz_sprawe",                                         default: true
    t.boolean  "zaakceptuj_dokument",                                    default: true
    t.datetime "data_utworzenia"
    t.integer  "identyfikator_osoby_tworzacej"
    t.datetime "data_modyfikacji"
    t.integer  "identyfikator_osoby_modyfikujacej"
    t.boolean  "initialized_from_esod",                                  default: false
    t.integer  "netpar_user"
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.integer  "document_id"
  end

  add_index "esod_outgoing_letters", ["tytul"], name: "index_esod_outgoing_letters_on_tytul", using: :btree

  create_table "esod_outgoing_letters_documents", force: :cascade do |t|
    t.integer  "esod_outgoing_letter_id"
    t.integer  "document_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "esod_outgoing_letters_documents", ["esod_outgoing_letter_id", "document_id"], name: "esod_outgoing_letters_documents_uniq", unique: true, using: :btree

  create_table "esod_outgoing_letters_matters", force: :cascade do |t|
    t.integer "esod_outgoing_letter_id"
    t.integer "esod_matter_id"
    t.integer "sprawa",                  limit: 8
    t.integer "dokument",                limit: 8
    t.string  "sygnatura"
    t.boolean "initialized_from_esod",             default: false
    t.integer "netpar_user"
  end

  add_index "esod_outgoing_letters_matters", ["esod_matter_id", "esod_outgoing_letter_id"], name: "esod_outgoing_letters_matters_matter_outgoing_letter", unique: true, using: :btree
  add_index "esod_outgoing_letters_matters", ["esod_matter_id"], name: "index_esod_outgoing_letters_matters_on_esod_matter_id", using: :btree
  add_index "esod_outgoing_letters_matters", ["esod_outgoing_letter_id", "esod_matter_id"], name: "esod_outgoing_letters_matters_outgoing_letter_matter", unique: true, using: :btree
  add_index "esod_outgoing_letters_matters", ["esod_outgoing_letter_id"], name: "index_esod_outgoing_letters_matters_on_esod_outgoing_letter_id", using: :btree

  create_table "exam_fees", force: :cascade do |t|
    t.integer  "division_id"
    t.integer  "esod_category"
    t.decimal  "price",         precision: 8, scale: 2
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "exam_fees", ["division_id", "esod_category"], name: "index_exam_fees_on_division_id_and_esod_category", unique: true, using: :btree

  create_table "examinations", force: :cascade do |t|
    t.integer  "division_id"
    t.string   "examination_result", limit: 1
    t.integer  "exam_id"
    t.integer  "customer_id"
    t.text     "note",                         default: ""
    t.string   "category",           limit: 1
    t.integer  "user_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "certificate_id"
    t.integer  "esod_category"
    t.integer  "proposal_id"
  end

  add_index "examinations", ["certificate_id"], name: "index_examinations_on_certificate_id", using: :btree
  add_index "examinations", ["customer_id"], name: "index_examinations_on_customer_id", using: :btree
  add_index "examinations", ["division_id"], name: "index_examinations_on_division_id", using: :btree
  add_index "examinations", ["exam_id"], name: "index_examinations_on_exam_id", using: :btree
  add_index "examinations", ["proposal_id"], name: "index_examinations_on_proposal_id", using: :btree
  add_index "examinations", ["user_id"], name: "index_examinations_on_user_id", using: :btree

  create_table "examiners", force: :cascade do |t|
    t.string   "name"
    t.integer  "exam_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "examiners", ["exam_id"], name: "index_examiners_on_exam_id", using: :btree

  create_table "exams", force: :cascade do |t|
    t.string   "number",                    limit: 30, default: "",    null: false
    t.date     "date_exam"
    t.string   "place_exam",                limit: 50, default: ""
    t.string   "chairman",                  limit: 50, default: ""
    t.string   "secretary",                 limit: 50, default: ""
    t.string   "category",                  limit: 1,  default: "R",   null: false
    t.text     "note",                                 default: ""
    t.integer  "user_id"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "examinations_count",                   default: 0
    t.integer  "certificates_count",                   default: 0
    t.integer  "esod_category"
    t.integer  "max_examinations"
    t.string   "province_name",             limit: 50, default: ""
    t.integer  "proposals_important_count",            default: 0
    t.string   "info",                                 default: ""
    t.string   "province_id",               limit: 2,  default: "",    null: false
    t.boolean  "online",                               default: false, null: false
  end

  add_index "exams", ["category"], name: "index_exams_on_category", using: :btree
  add_index "exams", ["date_exam"], name: "index_exams_on_date_exam", using: :btree
  add_index "exams", ["info"], name: "exams_info_idx", using: :gin
  add_index "exams", ["number", "category"], name: "index_exams_on_number_and_category", unique: true, using: :btree
  add_index "exams", ["number"], name: "exams_number_idx", using: :gin
  add_index "exams", ["place_exam"], name: "exams_place_exam_idx", using: :gin
  add_index "exams", ["province_name"], name: "exams_province_name_idx", using: :gin
  add_index "exams", ["user_id"], name: "index_exams_on_user_id", using: :btree

  create_table "exams_divisions", force: :cascade do |t|
    t.integer  "exam_id"
    t.integer  "division_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "exams_divisions", ["division_id"], name: "index_exams_divisions_on_division_id", using: :btree
  add_index "exams_divisions", ["exam_id", "division_id"], name: "index_exams_divisions_on_exam_id_and_division_id", unique: true, using: :btree
  add_index "exams_divisions", ["exam_id"], name: "index_exams_divisions_on_exam_id", using: :btree

  create_table "exams_divisions_subjects", force: :cascade do |t|
    t.integer  "exams_division_id"
    t.integer  "subject_id"
    t.string   "testportal_test_id", default: "", null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "exams_divisions_subjects", ["exams_division_id", "subject_id"], name: "exams_divisions_subjects_unique", unique: true, using: :btree
  add_index "exams_divisions_subjects", ["exams_division_id"], name: "index_exams_divisions_subjects_on_exams_division_id", using: :btree
  add_index "exams_divisions_subjects", ["subject_id"], name: "index_exams_divisions_subjects_on_subject_id", using: :btree

  create_table "grades", force: :cascade do |t|
    t.integer  "examination_id"
    t.integer  "subject_id"
    t.string   "grade_result",              limit: 1, default: ""
    t.integer  "user_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "testportal_access_code_id",           default: ""
  end

  add_index "grades", ["examination_id", "subject_id"], name: "index_grades_on_examination_id_and_subject_id", unique: true, using: :btree
  add_index "grades", ["examination_id"], name: "index_grades_on_examination_id", using: :btree
  add_index "grades", ["subject_id"], name: "index_grades_on_subject_id", using: :btree
  add_index "grades", ["user_id"], name: "index_grades_on_user_id", using: :btree

  create_table "licenses", force: :cascade do |t|
    t.string  "department"
    t.string  "number"
    t.string  "status"
    t.date    "date_of_issue"
    t.date    "valid_to"
    t.string  "call_sign"
    t.string  "category"
    t.integer "transmitter_power"
    t.string  "name_type_station"
    t.string  "destination"
    t.string  "input_frequency"
    t.string  "output_frequency"
    t.string  "emission"
    t.string  "operators"
    t.text    "note"
    t.string  "applicant_name"
    t.string  "applicant_location"
    t.string  "enduser_name"
    t.string  "enduser_location"
    t.string  "station_location"
    t.string  "type_license",       limit: 1
  end

  add_index "licenses", ["applicant_location"], name: "index_licenses_on_applicant_location", using: :btree
  add_index "licenses", ["applicant_name"], name: "index_licenses_on_applicant_name", using: :btree
  add_index "licenses", ["call_sign"], name: "index_licenses_on_call_sign", using: :btree
  add_index "licenses", ["enduser_location"], name: "index_licenses_on_enduser_location", using: :btree
  add_index "licenses", ["enduser_name"], name: "index_licenses_on_enduser_name", using: :btree
  add_index "licenses", ["number"], name: "index_licenses_on_number", using: :btree
  add_index "licenses", ["operators"], name: "index_licenses_on_operators", using: :btree
  add_index "licenses", ["station_location"], name: "index_licenses_on_station_location", using: :btree
  add_index "licenses", ["type_license"], name: "index_licenses_on_type_license", using: :btree

  create_table "old_passwords", force: :cascade do |t|
    t.string   "encrypted_password",       null: false
    t.string   "password_salt"
    t.string   "password_archivable_type", null: false
    t.integer  "password_archivable_id",   null: false
    t.datetime "created_at"
  end

  add_index "old_passwords", ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable", using: :btree

  create_table "proposal_statuses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "proposals", force: :cascade do |t|
    t.uuid     "multi_app_identifier",                                                       null: false
    t.integer  "proposal_status_id"
    t.string   "category",               limit: 1,                                           null: false
    t.integer  "user_id"
    t.integer  "creator_id"
    t.string   "name",                   limit: 160,                         default: "",    null: false
    t.string   "given_names",            limit: 50,                          default: "",    null: false
    t.string   "pesel",                  limit: 11,                          default: ""
    t.date     "birth_date"
    t.string   "birth_place",            limit: 50,                          default: ""
    t.string   "phone",                  limit: 50,                          default: ""
    t.string   "email",                  limit: 50,                          default: "",    null: false
    t.string   "c_address_house",        limit: 10,                          default: ""
    t.string   "c_address_number",       limit: 10,                          default: ""
    t.string   "c_address_postal_code",  limit: 10,                          default: ""
    t.integer  "esod_category"
    t.integer  "exam_id"
    t.string   "exam_fullname"
    t.date     "exam_date_exam"
    t.integer  "division_id"
    t.string   "division_fullname"
    t.integer  "exam_fee_id"
    t.decimal  "exam_fee_price",                     precision: 8, scale: 2, default: 0.0
    t.text     "face_image_blob_path"
    t.text     "bank_pdf_blob_path"
    t.text     "not_approved_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "division_min_years_old"
    t.string   "division_short_name"
    t.integer  "customer_id"
    t.string   "family_name",                                                default: ""
    t.string   "citizenship_code",                                           default: ""
    t.text     "consent_pdf_blob_path"
    t.boolean  "lives_in_poland"
    t.string   "province_code",          limit: 20,                          default: ""
    t.string   "province_name",          limit: 50,                          default: ""
    t.string   "district_code",          limit: 20,                          default: ""
    t.string   "district_name",          limit: 50,                          default: ""
    t.string   "commune_code",           limit: 20,                          default: ""
    t.string   "commune_name",           limit: 50,                          default: ""
    t.string   "city_code",              limit: 20,                          default: ""
    t.string   "city_name",              limit: 50,                          default: ""
    t.string   "city_parent_code",       limit: 20,                          default: ""
    t.string   "city_parent_name",       limit: 50,                          default: ""
    t.string   "street_code",            limit: 20,                          default: ""
    t.string   "street_name",            limit: 50,                          default: ""
    t.string   "street_attribute",       limit: 20,                          default: ""
    t.string   "address_combine_id",     limit: 26,                          default: ""
    t.boolean  "exam_online",                                                default: false, null: false
  end

  add_index "proposals", ["category"], name: "index_proposals_on_category", using: :btree
  add_index "proposals", ["customer_id"], name: "index_proposals_on_customer_id", using: :btree
  add_index "proposals", ["division_id"], name: "index_proposals_on_division_id", using: :btree
  add_index "proposals", ["exam_fee_id"], name: "index_proposals_on_exam_fee_id", using: :btree
  add_index "proposals", ["exam_id"], name: "index_proposals_on_exam_id", using: :btree
  add_index "proposals", ["multi_app_identifier"], name: "index_proposals_on_multi_app_identifier", using: :btree
  add_index "proposals", ["pesel"], name: "index_proposals_on_pesel", using: :btree
  add_index "proposals", ["proposal_status_id"], name: "index_proposals_on_proposal_status_id", using: :btree
  add_index "proposals", ["user_id"], name: "index_proposals_on_user_id", using: :btree

  create_table "refile_attachments", force: :cascade do |t|
    t.integer  "oid",        null: false
    t.string   "namespace",  null: false
    t.datetime "created_at"
  end

  add_index "refile_attachments", ["namespace"], name: "index_refile_attachments_on_namespace", using: :btree
  add_index "refile_attachments", ["oid"], name: "index_refile_attachments_on_oid", using: :btree

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
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "esod_categories", default: [],              array: true
    t.string   "test_template",   default: ""
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
    t.string   "esod_token"
    t.datetime "esod_token_expired_at"
    t.string   "wso2_name"
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
  add_foreign_key "customers", "users"
  add_foreign_key "esod_addresses", "customers"
  add_foreign_key "esod_contractors", "customers"
  add_foreign_key "esod_incoming_letters", "esod_addresses"
  add_foreign_key "esod_incoming_letters", "esod_contractors"
  add_foreign_key "esod_incoming_letters_matters", "esod_incoming_letters"
  add_foreign_key "esod_incoming_letters_matters", "esod_matters"
  add_foreign_key "esod_internal_letters_matters", "esod_internal_letters"
  add_foreign_key "esod_internal_letters_matters", "esod_matters"
  add_foreign_key "esod_matter_notes", "esod_matters"
  add_foreign_key "esod_matters", "certificates"
  add_foreign_key "esod_matters", "examinations"
  add_foreign_key "esod_matters", "exams"
  add_foreign_key "esod_outgoing_letters_matters", "esod_matters"
  add_foreign_key "esod_outgoing_letters_matters", "esod_outgoing_letters"
  add_foreign_key "exam_fees", "divisions"
  add_foreign_key "examinations", "certificates"
  add_foreign_key "examinations", "customers"
  add_foreign_key "examinations", "divisions"
  add_foreign_key "examinations", "exams"
  add_foreign_key "examinations", "proposals"
  add_foreign_key "examinations", "users"
  add_foreign_key "examiners", "exams"
  add_foreign_key "exams", "users"
  add_foreign_key "exams_divisions", "divisions"
  add_foreign_key "exams_divisions", "exams"
  add_foreign_key "exams_divisions_subjects", "exams_divisions", on_delete: :cascade
  add_foreign_key "grades", "examinations"
  add_foreign_key "grades", "subjects"
  add_foreign_key "grades", "users"
  add_foreign_key "proposals", "divisions"
  add_foreign_key "proposals", "exam_fees"
  add_foreign_key "proposals", "exams"
  add_foreign_key "proposals", "proposal_statuses"
  add_foreign_key "subjects", "divisions"
  add_foreign_key "users", "departments"
end
