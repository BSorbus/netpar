require 'rails_helper'

RSpec.describe Teryt::SimcCode, type: :model do
  let(:teryt_simc_code) { FactoryGirl.build :teryt_simc_code }
  subject { teryt_simc_code }

  it { should respond_to(:woj) }
  it { should respond_to(:pow) }
  it { should respond_to(:gmi) }
  it { should respond_to(:rodz_gmi) }
  it { should respond_to(:rm) }
  it { should respond_to(:mz) }
  it { should respond_to(:nazwa) }
  it { should respond_to(:sym) }
  it { should respond_to(:sympod) }
  it { should respond_to(:stan_na) }
end
