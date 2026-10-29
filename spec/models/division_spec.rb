require 'rails_helper'

RSpec.describe Division, type: :model do
  let(:division) { FactoryBot.build :division }
  subject { division }

  it { should respond_to(:name) }
  it { should respond_to(:english_name) }
  it { should respond_to(:category) }
  it { should respond_to(:short_name) }
  it { should respond_to(:number_prefix) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:category).case_insensitive }
  it { should validate_presence_of(:category) }
  # it { should validate_inclusion_of(:category).in_array(['L', 'M', 'R']) }
  it { should validate_inclusion_of(:category).in_array(%w(L M R)) }

  it { should validate_presence_of(:short_name) }
  it { should validate_presence_of(:number_prefix) }

  it { should have_many(:subjects) }
  it { should have_many(:certificates) }

  it { should accept_nested_attributes_for(:subjects) }

  describe '#subjects association' do
    before do
      division.save
      3.times { FactoryBot.create :subject, division: division }
    end

    it 'destroys the associated subjects on self destruct' do
      my_subjects = division.subjects
      division.destroy
      my_subjects.each do |my_subject|
        expect(Subject.find(my_subject)).to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe 'enabled_in_confirmation' do
    it 'domyślnie wyłączone' do
      expect(Division.new.enabled_in_confirmation).to be false
    end

    it 'scope only_enabled_in_confirmation' do
      enabled = FactoryBot.create :division, short_name: 'e', english_name: 'E', enabled_in_confirmation: true
      FactoryBot.create :division, short_name: 'd', english_name: 'D', enabled_in_confirmation: false

      expect(Division.only_enabled_in_confirmation).to eq [enabled]
    end
  end

  describe '.finder_query' do
    it 'szuka każdego słowa w nazwie lub skrócie, bez warunku kategorii' do
      src = FactoryBot.create :division, category: 'M', name: 'świadectwo operatora łączności bliskiego zasięgu SRC', short_name: 'SRC', english_name: 'SRC'
      FactoryBot.create :division, category: 'L', name: 'świadectwo ogólne operatora radiotelefonisty', short_name: 'OR', english_name: 'OR'

      expect(Division.finder_query('src')).to eq [src]
      expect(Division.finder_query('operatora zasięgu')).to eq [src]
      expect(Division.finder_query("x' OR '1'='1")).to be_empty
    end
  end
end

