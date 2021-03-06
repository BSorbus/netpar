require 'rails_helper'

RSpec.describe Examination, type: :model do
  let(:examination) { FactoryBot.build :examination }
  subject { examination }

  it { should respond_to(:division_id) }
  it { should respond_to(:examination_result) }
  it { should respond_to(:exam_id) }
  it { should respond_to(:customer_id) }
  it { should respond_to(:note) }
  it { should respond_to(:category) }
  it { should respond_to(:user_id) }
  it { should respond_to(:certificate_id) }
  it { should respond_to(:esod_category) }

  it { should validate_presence_of(:category) }
  # it { should validate_inclusion_of(:category).in_array(['L', 'M', 'R']) }
  it { should validate_inclusion_of(:category).in_array(%w(L M R)) }

  it { should validate_presence_of(:esod_category) }
  it { should validate_inclusion_of(:esod_category).in_array(Esodes::ALL_CATEGORIES_EXAMINATIONS) }

  it { should validate_presence_of(:division) }
  it { should validate_presence_of(:customer) }
  it { should validate_presence_of(:exam) }
  it { should validate_presence_of(:user) }

  it { should belong_to :division }
  it { should belong_to :exam }
  it { should belong_to :customer }
  it { should belong_to :user }
  it { should belong_to :certificate }

  it { should have_many(:documents) }
  it { expect(examination).to have_many(:documents).dependent(:destroy) }
  it { should have_many(:works) }
  it { should have_many(:grades) }
  it { expect(examination).to have_many(:grades).dependent(:destroy) }

  it { should accept_nested_attributes_for(:grades) }
  #  describe "#grades association" do
  #
  #    before do
  #      examination.save
  #      3.times { FactoryBot.create :grade, examination: examination }
  #    end
  #
  #    it "destroys the associated grades on self destruct" do
  #      grades = examination.grades
  #      examination.destroy
  #      grades.each do |grade|
  #        expect(Subject.find(grade)).to raise_error ActiveRecord::RecordNotFound
  #      end
  #    end
  #  end
end
