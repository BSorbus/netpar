require 'rails_helper'

RSpec.describe Grade, type: :model do
  let(:grade) { FactoryBot.build :grade }
  subject { grade }

  it { should respond_to(:examination_id) }
  it { should respond_to(:subject_id) }
  it { should respond_to(:grade_result) }
  it { should respond_to(:user_id) }

  it { should validate_presence_of(:examination) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:user) }
  it { should validate_inclusion_of(:grade_result).in_array(['', nil, 'N', 'P']) }

  it { should belong_to :examination }
  it { should belong_to :subject }
  it { should belong_to :user }
end
