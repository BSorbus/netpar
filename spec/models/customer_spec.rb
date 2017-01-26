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
  it { should respond_to(:address_in_poland) }
  it { should respond_to(:address_teryt_pna_code_id) }
  it { should respond_to(:c_address_in_poland) }
  it { should respond_to(:c_address_teryt_pna_code_id) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1).is_at_most(160) }

  it { should validate_presence_of(:address_city) }
  it { should validate_length_of(:address_city).is_at_least(1).is_at_most(50) }
  it { should validate_presence_of(:address_postal_code) }
  it { should validate_length_of(:address_postal_code).is_at_least(6).is_at_most(10) }

  context 'when is a human' do
    before do
      customer.human = true
    end
    subject { customer }

    it { should validate_presence_of(:given_names) }
    it { should validate_length_of(:given_names).is_at_least(1).is_at_most(50) }

    it { should validate_presence_of(:birth_date) }
  end

  context 'when is not a human' do
    before do
      customer.human = false
    end
    subject { customer }

    it { should_not validate_presence_of(:given_names) }
    it { should_not validate_length_of(:given_names).is_at_least(1).is_at_most(50) }

    it { should_not validate_presence_of(:birth_date) }
  end

  context 'when c_address_postal_code present' do
    before do
      customer.c_address_postal_code = '12-345'
    end
    subject { customer }

    it { should validate_length_of(:c_address_postal_code).is_at_least(6).is_at_most(10) }
  end

  # validates :c_address_postal_code,
  #                   length: { in: 6..10 }, if: "c_address_postal_code.present?"
  # validates :pesel, length: { is: 11 }, numericality: true,
  #                   uniqueness: { case_sensitive: false }, allow_blank: true
  # validate :check_pesel_and_birth_date, unless: "pesel.blank?"
  # validate :unique_name_given_names_birth_date_birth_place_fathers_name, if: :is_human?

  it { should validate_presence_of(:citizenship) }
  it { should validate_presence_of(:user) }

  it { should belong_to :citizenship }
  it { should belong_to :user }

  it { should belong_to :address_teryt_pna_code }
  it { should belong_to :c_address_teryt_pna_code }

  it { should have_many(:documents) }
  it { should have_many(:works) }
  it { should have_many(:certificates) }
  it { should have_many(:examinations) }
  it { should have_many(:exams) }

  it { should have_many(:certificated_documentable) }
  it { should have_many(:examinationed_documentable) }
  it { should have_many(:examed_documentable) }
end
