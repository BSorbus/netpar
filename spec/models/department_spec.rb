require 'spec_helper'

RSpec.describe Department, type: :model do
  let(:department) { FactoryBot.build :department }
  subject { department }

  it { should respond_to(:short) }
  it { should respond_to(:name) }
  it { should respond_to(:address_city) }
  it { should respond_to(:address_street) }
  it { should respond_to(:address_house) }
  it { should respond_to(:address_number) }
  it { should respond_to(:address_postal_code) }
  it { should respond_to(:phone) }
  it { should respond_to(:fax) }
  it { should respond_to(:email) }
  it { should respond_to(:director) }

  it { should validate_presence_of(:short) }
  it { should validate_length_of(:short).is_at_least(1).is_at_most(15) }
  it { should validate_uniqueness_of(:short).case_insensitive }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1).is_at_most(100) }
  it { should validate_uniqueness_of(:name).case_insensitive }

  it { should validate_presence_of(:address_city) }
  it { should validate_length_of(:address_city).is_at_least(1).is_at_most(50) }

  it { should have_many(:users) }
  it { should have_many(:works) }
end
