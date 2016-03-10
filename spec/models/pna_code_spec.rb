require 'rails_helper'

RSpec.describe PnaCode, type: :model do
  let(:pna_code) { FactoryGirl.build :pna_code }
  subject { pna_code }

  it { should respond_to(:pna) }
  it { should respond_to(:miejscowosc) }
  it { should respond_to(:ulica) }
  it { should respond_to(:numery) }
  it { should respond_to(:wojewodztwo) }
  it { should respond_to(:powiat) }
  it { should respond_to(:gmina) }

  it { should validate_presence_of(:pna) }
  it { should validate_length_of(:pna).is_at_least(6).is_at_most(10) }

  it { should validate_presence_of(:miejscowosc) }
  it { should validate_presence_of(:wojewodztwo) }
  it { should validate_presence_of(:powiat) }
  it { should validate_presence_of(:gmina) }

end
