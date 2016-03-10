require 'rails_helper'

RSpec.describe EsodCase, type: :model do
  let(:esod_case) { FactoryGirl.build :esod_case }
  subject { esod_case }

  it { should respond_to(:nrid) }
  it { should respond_to(:znak) }
  it { should respond_to(:znak_sprawy_grupujacej) }
  it { should respond_to(:symbol_jrwa) }
  it { should respond_to(:tytul) }
  it { should respond_to(:termin_realizacji) }
  it { should respond_to(:identyfikator_kategorii_sprawy) }
  it { should respond_to(:adnotacja) }
  it { should respond_to(:identyfikator_stanowiska_referenta) }
#  it { should respond_to(:czy_otwarta) }
  it { should respond_to(:esod_created_at) }
  it { should respond_to(:esod_updated_et) }

  it { should validate_presence_of(:nrid) }
  it { should validate_numericality_of(:nrid) }
  it { should validate_uniqueness_of(:nrid) }

  it { should validate_presence_of(:znak) }
  it { should validate_uniqueness_of(:znak).case_insensitive }
 
end
