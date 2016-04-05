require 'rails_helper'

RSpec.describe TerytTercCode, type: :model do
  let(:teryt_terc_code) { FactoryGirl.build :teryt_terc_code }
  subject { teryt_terc_code }

  it { should respond_to(:woj) }
  it { should respond_to(:pow) }
  it { should respond_to(:gmi) }
  it { should respond_to(:rodz) }
  it { should respond_to(:nazwa) }
  it { should respond_to(:nazdod) }
  it { should respond_to(:stan_na) }

#  it { should validate_presence_of(:item) }
#  it { should validate_numericality_of(:item) }
#  it { should validate_uniqueness_of(:item).scoped_to(:division_id, :for_supplementary).case_insensitive }

#  it { should validate_presence_of(:name) }
#  it { should validate_length_of(:name).is_at_least(1).is_at_most(150) }
#  it { should validate_uniqueness_of(:name).scoped_to(:division_id, :for_supplementary).case_insensitive }

#  it { should validate_presence_of(:division) }

#  it { should belong_to :division }

#  it { should have_many(:grades) }

end
