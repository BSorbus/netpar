# Represents Client UKE
#  create_table "customers", force: :cascade do |t|
#    t.boolean  "human",                             default: true, null: false
#    t.string   "name",                  limit: 160, default: "",   null: false
#    t.string   "given_names",           limit: 50,  default: ""
#    t.string   "address_city",          limit: 50,  default: ""
#    t.string   "address_street",        limit: 50,  default: ""
#    t.string   "address_house",         limit: 10,  default: ""
#    t.string   "address_number",        limit: 10,  default: ""
#    t.string   "address_postal_code",   limit: 10,  default: ""
#    t.string   "address_post_office",   limit: 50,  default: ""
#    t.string   "address_pobox",         limit: 10,  default: ""
#    t.string   "c_address_city",        limit: 50,  default: ""
#    t.string   "c_address_street",      limit: 50,  default: ""
#    t.string   "c_address_house",       limit: 10,  default: ""
#    t.string   "c_address_number",      limit: 10,  default: ""
#    t.string   "c_address_postal_code", limit: 10,  default: ""
#    t.string   "c_address_post_office", limit: 50,  default: ""
#    t.string   "c_address_pobox",       limit: 10,  default: ""
#    t.string   "nip",                   limit: 13,  default: ""
#    t.string   "regon",                 limit: 9,   default: ""
#    t.string   "pesel",                 limit: 11,  default: ""
#    t.date     "birth_date"
#    t.string   "birth_place",           limit: 50,  default: ""
#    t.string   "fathers_name",          limit: 50,  default: ""
#    t.string   "mothers_name",          limit: 50,  default: ""
#    t.string   "family_name",           limit: 50,  default: ""
#    t.integer  "citizenship_id",                    default: 2
#    t.string   "phone",                 limit: 50,  default: ""
#    t.string   "fax",                   limit: 50,  default: ""
#    t.string   "email",                 limit: 50,  default: ""
#    t.text     "note",                              default: ""
#    t.integer  "user_id"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
#  add_index "customers", ["address_city"], name: "index_customers_on_address_city", using: :btree
#  add_index "customers", ["birth_date"], name: "index_customers_on_birth_date", using: :btree
#  add_index "customers", ["citizenship_id"], name: "index_customers_on_citizenship_id", using: :btree
#  add_index "customers", ["given_names"], name: "index_customers_on_given_names", using: :btree
#  add_index "customers", ["name"], name: "index_customers_on_name", using: :btree
#  add_index "customers", ["nip"], name: "index_customers_on_nip", using: :btree
#  add_index "customers", ["pesel"], name: "index_customers_on_pesel", using: :btree
#  add_index "customers", ["regon"], name: "index_customers_on_regon", using: :btree
#  add_index "customers", ["user_id"], name: "index_customers_on_user_id", using: :btree
#
RSpec.describe Customer, type: :model do
  let(:customer) { FactoryGirl.build :customer }
  subject { customer }

  it { should respond_to(:human) }
  it { should respond_to(:name) }
  it { should respond_to(:given_names) }
  it { should respond_to(:address_city) }
  it { should respond_to(:address_street) }
  it { should respond_to(:address_house) }
  it { should respond_to(:address_number) }
  it { should respond_to(:address_postal_code) }
  it { should respond_to(:address_post_office) }
  it { should respond_to(:address_pobox) }
  it { should respond_to(:c_address_city) }
  it { should respond_to(:c_address_street) }
  it { should respond_to(:c_address_house) }
  it { should respond_to(:c_address_number) }
  it { should respond_to(:c_address_postal_code) }
  it { should respond_to(:c_address_post_office) }
  it { should respond_to(:c_address_pobox) }
  it { should respond_to(:nip) }
  it { should respond_to(:regon) }
  it { should respond_to(:pesel) }
  it { should respond_to(:birth_date) }
  it { should respond_to(:birth_place) }
  it { should respond_to(:fathers_name) }
  it { should respond_to(:mothers_name) }
  it { should respond_to(:family_name) }
  it { should respond_to(:citizenship_id) }
  it { should respond_to(:phone) }
  it { should respond_to(:fax) }
  it { should respond_to(:email) }
  it { should respond_to(:note) }
  it { should respond_to(:user_id) }


  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1).is_at_most(160) }

  it { should validate_presence_of(:address_city) }
  it { should validate_length_of(:address_city).is_at_least(1).is_at_most(50) }
  it { should validate_presence_of(:address_postal_code) }
  it { should validate_length_of(:address_postal_code).is_at_least(6).is_at_most(10) }


  describe "a Customer is a human" do 
    before(:each) { @customer = FactoryGirl.build :customer, human: true }
    subject { @customer }
 
    it { should validate_presence_of(:given_names) } 
    it { should validate_length_of(:given_names).is_at_least(1).is_at_most(50) }

    it { should validate_presence_of(:birth_date) } 
  end

  describe "a Customer is not a human" do 
    before(:each) { @customer = FactoryGirl.build :customer, human: false }
    subject { @customer }
 
    it { should_not validate_presence_of(:given_names) } 
    it { should_not validate_length_of(:given_names).is_at_least(1).is_at_most(50) }

    it { should_not validate_presence_of(:birth_date) } 
  end

#  validates :c_address_postal_code,
#                    length: { in: 6..10 }, if: "c_address_postal_code.present?"
#  validates :pesel, length: { is: 11 }, numericality: true, 
#                    uniqueness: { case_sensitive: false }, allow_blank: true
#  validate :check_pesel_and_birth_date, unless: "pesel.blank?"
#  validate :unique_name_given_names_birth_date_birth_place_fathers_name, if: :is_human?

  it { should validate_presence_of(:citizenship) }
  it { should validate_presence_of(:user) }



  it { should belong_to :citizenship }
  it { should belong_to :user }

  it { should have_many(:documents) }
  it { should have_many(:works) }
  it { should have_many(:certificates) }
  it { should have_many(:examinations) }
  it { should have_many(:exams) }

  it { should have_many(:certificated_documentable) }
  it { should have_many(:examinationed_documentable) }
  it { should have_many(:examed_documentable) }

end

