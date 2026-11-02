RSpec.describe Customer, type: :model do
  let(:customer) { FactoryBot.build :customer }
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
  it { should respond_to(:citizenship_code) }
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

  it { should validate_presence_of(:user) }

  it { should belong_to :user }

  it { should have_many(:documents) }
  it { should have_many(:works) }
  it { should have_many(:certificates) }
  it { should have_many(:examinations) }
  it { should have_many(:exams) }

  it { should have_many(:certificated_documentable) }
  it { should have_many(:examinationed_documentable) }
  it { should have_many(:examed_documentable) }

  # Zgłoszenia z aplikacji Egzaminy – imiona i nazwisko często wielkimi literami; korekta w danych osoby (strona wniosku).
  describe 'imiona i nazwisko' do
    it 'name_case: tekst wielkimi (albo małymi) literami – pierwsza wielka, także po łączniku; inny bez zmian' do
      expect(Customer.name_case('BOGDAN')).to eq 'Bogdan'
      expect(Customer.name_case(' JARZĄB ')).to eq 'Jarząb'
      expect(Customer.name_case('KOWALSKI-NOWAK')).to eq 'Kowalski-Nowak'
      expect(Customer.name_case('ŁUKASZ ŻÓŁTY')).to eq 'Łukasz Żółty'
      expect(Customer.name_case('jan maria')).to eq 'Jan Maria'
      expect(Customer.name_case('McDonald')).to eq 'McDonald'
      expect(Customer.name_case('Jarzab')).to eq 'Jarzab' # brakujących polskich znaków nie da się odtworzyć
      expect(Customer.name_case(nil)).to eq ''
    end

    it 'name_in_capitals? i certificate_name (jak na świadectwie i karcie)' do
      expect(Customer.new(name: 'JARZĄB', given_names: 'Bogdan').name_in_capitals?).to be true
      expect(Customer.new(name: 'Jarząb', given_names: 'BOGDAN').name_in_capitals?).to be true
      expect(Customer.new(name: 'Jarząb', given_names: 'Bogdan').name_in_capitals?).to be false
      expect(Customer.new(name: 'Ng', given_names: 'Li').name_in_capitals?).to be false
      expect(Customer.new(name: 'Jarząb', given_names: 'Bogdan').certificate_name).to eq 'Bogdan JARZĄB'
    end
  end
end
