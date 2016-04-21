require 'rails_helper'

RSpec.describe Teryt::PnaCode, type: :model do
  let(:teryt_pna_code) { FactoryGirl.build :teryt_pna_code }
  subject { teryt_pna_code }

  it { should respond_to(:woj) }
  it { should respond_to(:woj_nazwa) }
  it { should respond_to(:pow) }

#  pending "add some examples to (or delete) #{__FILE__}"

end
