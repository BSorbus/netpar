require 'rails_helper'

RSpec.describe Subject, type: :model do
  let(:my_subject) { FactoryGirl.build :subject }
  subject { my_subject }

  it { should respond_to(:item) }
  it { should respond_to(:name) }
  it { should respond_to(:division_id) }
  it { should respond_to(:esod_categories) }

  it { should validate_presence_of(:item) }
  it { should validate_numericality_of(:item) }
  it { should validate_uniqueness_of(:item).scoped_to(:division_id, :esod_categories).case_insensitive }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1).is_at_most(150) }
  it { should validate_uniqueness_of(:name).scoped_to(:division_id, :esod_categories).case_insensitive }

  it { should validate_presence_of(:division) }

  it { should belong_to :division }

  it { should have_many(:grades) }

end
