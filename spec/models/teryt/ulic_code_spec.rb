require 'rails_helper'

RSpec.describe Teryt::UlicCode, type: :model do
  let(:teryt_ulic_code) { FactoryGirl.build :teryt_ulic_code }
  subject { teryt_ulic_code }

  it { should respond_to(:woj) }
  it { should respond_to(:pow) }
  it { should respond_to(:gmi) }
  it { should respond_to(:rodz_gmi) }
  it { should respond_to(:sym) }
  it { should respond_to(:sym_ul) }
  it { should respond_to(:cecha) }
  it { should respond_to(:nazwa_1) }
  it { should respond_to(:nazwa_2) }
  it { should respond_to(:stan_na) }
end
