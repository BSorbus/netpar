require 'spec_helper'

RSpec.describe Role, type: :model do
  let(:role) { FactoryGirl.build :role }
  subject { role }

  it { should respond_to(:name) }
  it { should respond_to(:activities) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1).is_at_most(100) }
  it { should validate_uniqueness_of(:name).case_insensitive }


  it { should have_and_belong_to_many(:users) }
  it { should have_many(:works) }

end
