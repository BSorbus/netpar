require 'rails_helper'

RSpec.describe Citizenship, type: :model do
  let(:citizenship) { FactoryGirl.build :citizenship }
  subject { citizenship }

  it { should respond_to(:name) }
  it { should respond_to(:short) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_presence_of(:short) }
  it { should validate_uniqueness_of(:short).case_insensitive }

  it { should have_many(:customers) }

  context 'when name is blank' do
    citizenship = FactoryGirl.build :citizenship, name: nil

    it 'should not be valid' do
      expect(citizenship).to_not be_valid
    end

    it "should raise error: #{I18n.t('errors.messages.blank')}" do
      expect(citizenship.errors[:name]).to include(I18n.t('errors.messages.blank'))
    end
  end

  context 'when short is blank' do
    citizenship = FactoryGirl.build :citizenship, short: nil

    it 'should not be valid' do
      expect(citizenship).to_not be_valid
    end

    it "should raise error: #{I18n.t('errors.messages.blank')}" do
      expect(citizenship.errors[:short]).to include(I18n.t('errors.messages.blank'))
    end
  end
end
