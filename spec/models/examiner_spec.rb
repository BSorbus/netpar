require 'rails_helper'

RSpec.describe Examiner, type: :model do
  let(:examiner) { FactoryGirl.build :examiner }
  subject { examiner }

  it { should respond_to(:name) }
  it { should respond_to(:exam_id) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1).is_at_most(50) }
  it { should validate_uniqueness_of(:name).scoped_to(:exam_id).case_insensitive }

  it { should validate_presence_of(:exam) }

  it { should belong_to :exam }
end
