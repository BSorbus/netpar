require 'rails_helper'

RSpec.describe Certificate, type: :model do
  let(:certificate) { FactoryGirl.build :certificate }
  subject { certificate }

  it { should respond_to(:number) }
  it { should respond_to(:date_of_issue) }
  it { should respond_to(:certificate_status) }
  it { should respond_to(:division_id) }
  it { should respond_to(:exam_id) }
  it { should respond_to(:customer_id) }
  it { should respond_to(:note) }
  it { should respond_to(:category) }
  it { should respond_to(:user_id) }

  it { should validate_presence_of(:number) }
  it { should validate_length_of(:number).is_at_least(1).is_at_most(30) }
  it { should validate_uniqueness_of(:number).scoped_to(:category).case_insensitive }
  it { should validate_presence_of :date_of_issue }
  it { should validate_presence_of(:division) }
  it { should validate_presence_of(:customer) }
  it { should validate_presence_of(:exam) }
  it { should validate_presence_of(:user) }

  it { should validate_presence_of(:category) }
  it { should validate_inclusion_of(:category).in_array(['L', 'M', 'R']) }
  #it { should validate_inclusion_of(:category).in_array(%w(L M R)) }


  it { should belong_to :division }
  it { should belong_to :exam }
  it { should belong_to :customer }
  it { should belong_to :user }

  it { should have_one(:examination) }

  it { should have_many(:works) }
  it { should have_many(:documents) }


  context 'when name is blank' do
    certificate = FactoryGirl.build :certificate, number: nil

    it "should not be valid" do
      expect(certificate).to_not be_valid
    end

    it "should raise error: #{I18n.t('errors.messages.blank')}" do
      expect(certificate.errors[:number]).to include( I18n.t("errors.messages.blank") )
    end
  end

  context 'when number is to short' do
    certificate = FactoryGirl.build :certificate, number: ""

    it "should not be valid" do
      expect(certificate).to_not be_valid
    end

    it "should raise error: #{I18n.t('errors.messages.too_short', count: 1)}" do
      expect(certificate.errors[:number]).to include( I18n.t("errors.messages.too_short", count: 1) )
    end
  end

  context 'when number is to long' do
    certificate = FactoryGirl.build :certificate, number: "123" * 11

    it "should not be valid" do
      expect(certificate).to_not be_valid
    end

    it "should raise error: #{I18n.t('errors.messages.too_long', count: 30)}" do
      expect(certificate.errors[:number]).to include( I18n.t("errors.messages.too_long", count: 30) )
    end
  end


  context 'when date_of_issue is blank' do
    certificate = FactoryGirl.build :certificate, date_of_issue: nil

    it "should not be valid" do
      expect(certificate).to_not be_valid
    end

    it "should raise error: #{I18n.t('errors.messages.blank')}" do
      expect(certificate.errors[:date_of_issue]).to include( I18n.t("errors.messages.blank") )
    end
  end

  context 'when valid_thru is present and < date_of_issue' do
    certificate = FactoryGirl.build :certificate, date_of_issue: DateTime.now.to_date, valid_thru: DateTime.now.to_date - 1.day

    it "should not be valid" do
      expect(certificate).to_not be_valid
    end

    it "should raise error: nie może być mniejsza od daty wydania" do
      expect(certificate.errors[:valid_thru]).to include( "nie może być mniejsza od daty wydania" )
    end
  end

  context 'when division is blank' do
    certificate = FactoryGirl.build :certificate, division: nil

    it "should not be valid" do
      expect(certificate).to_not be_valid
    end

    it "should raise error: #{I18n.t('errors.messages.blank')}" do
      expect(certificate.errors[:division]).to include( I18n.t("errors.messages.blank") )
    end
  end

  context 'when customer is blank' do
    certificate = FactoryGirl.build :certificate, customer: nil

    it "should not be valid" do
      expect(certificate).to_not be_valid
    end

    it "should raise error: #{I18n.t('errors.messages.blank')}" do
      expect(certificate.errors[:customer]).to include( I18n.t("errors.messages.blank") )
    end
  end

  context 'when exam is blank' do
    certificate = FactoryGirl.build :certificate, exam: nil

    it "should not be valid" do
      expect(certificate).to_not be_valid
    end

    it "should raise error: #{I18n.t('errors.messages.blank')}" do
      expect(certificate.errors[:exam]).to include( I18n.t("errors.messages.blank") )
    end
  end

  context 'when user is blank' do
    certificate = FactoryGirl.build :certificate, user: nil

    it "should not be valid" do
      expect(certificate).to_not be_valid
    end

    it "should raise error: #{I18n.t('errors.messages.blank')}" do
      expect(certificate.errors[:user]).to include( I18n.t("errors.messages.blank") )
    end
  end

  describe '#with trait :lot' do
    let(:certificate_lot) {FactoryGirl.build :certificate, :lot }
    subject { certificate_lot }

    it "#category returns 'L'" do
      expect(certificate_lot.category).to match 'L'
    end
  end  

  describe '#with trait :mor' do
    let(:certificate_mor) { FactoryGirl.build :certificate, :mor }
    subject { certificate_mor }

    it "#category returns 'M'" do
      expect(certificate_mor.category).to match 'M'
    end
  end  

  describe '#with trait :ra' do
    #before(:each) { @certificate = FactoryGirl.build :certificate, :ra }
    #subject { @certificate }
    let(:certificate_ra) { FactoryGirl.build :certificate, :ra }
    subject { certificate_ra }

    it "#category returns 'R'" do
      #expect(@certificate.category).to match 'R'
      expect(certificate_ra.category).to match 'R'
    end
  end  

end

