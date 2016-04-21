require 'rails_helper'

RSpec.describe Teryt::TercCode, type: :model do
  let(:teryt_terc_code) { FactoryGirl.build :teryt_terc_code }
  subject { teryt_terc_code }

  it { should respond_to(:woj) }
  it { should respond_to(:pow) }
  it { should respond_to(:gmi) }
  it { should respond_to(:rodz) }
  it { should respond_to(:nazwa) }
  it { should respond_to(:nazdod) }
  it { should respond_to(:stan_na) }


end
