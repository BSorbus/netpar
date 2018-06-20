require 'rails_helper'

RSpec.describe Exam, type: :model do
  let(:exam) { FactoryGirl.build :exam }
  subject { exam }

  it { should respond_to(:number) }
  it { should respond_to(:date_exam) }
  it { should respond_to(:place_exam) }
  it { should respond_to(:chairman) }
  it { should respond_to(:secretary) }
  it { should respond_to(:category) }
  it { should respond_to(:note) }
  it { should respond_to(:user_id) }
  it { should respond_to(:examinations_count) }
  it { should respond_to(:certificates_count) }
  it { should respond_to(:esod_category) }

  it { should validate_presence_of(:esod_category) }
  it { should validate_inclusion_of(:esod_category).in_array(Esodes::ALL_CATEGORIES_EXAMS) }
  it { should validate_presence_of(:number) }
  it { should validate_length_of(:number).is_at_least(1).is_at_most(30) }
  it { should validate_uniqueness_of(:number).scoped_to(:category).case_insensitive }
  it { should validate_presence_of(:date_exam) }
  it { should validate_presence_of(:place_exam) }
  it { should validate_length_of(:place_exam).is_at_least(1).is_at_most(50) }
  it { should validate_presence_of(:category) }
  # it { should validate_inclusion_of(:category).in_array(['L', 'M', 'R']) }
  it { should validate_inclusion_of(:category).in_array(%w(L M R)) }
  it { should validate_presence_of(:user) }

  it { should belong_to :user }

  it { should have_many(:documents) }
  it { should have_many(:works) }
  it { should have_many(:certificates) }
  it { should have_many(:examinations) }
  it { should have_many(:examiners) }

  it { should have_many(:certificate_customers) }
  it { should have_many(:examination_customers) }

  it { should accept_nested_attributes_for(:examiners) }

  describe '#examiners association' do
    before do
      exam.save
      3.times { FactoryGirl.create :examiner, exam: exam }
    end

    it 'destroys the associated examiners on self destruct' do
      examiners = exam.examiners
      exam.destroy
      examiners.each do |examiner|
        expect(Subject.find(examiner)).to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
