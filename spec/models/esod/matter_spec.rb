require 'rails_helper'

RSpec.describe Esod::Matter, type: :model do
  let(:esod_matter) { FactoryBot.build :esod_matter }
  subject { esod_matter }

  it { should respond_to(:nrid) }
  it { should respond_to(:znak) }
  it { should respond_to(:znak_sprawy_grupujacej) }
  it { should respond_to(:symbol_jrwa) }
  it { should respond_to(:tytul) }
  it { should respond_to(:termin_realizacji) }
  it { should respond_to(:identyfikator_kategorii_sprawy) }
  it { should respond_to(:adnotacja) }
  it { should respond_to(:identyfikator_stanowiska_referenta) }
  it { should respond_to(:czy_otwarta) }
  it { should respond_to(:data_utworzenia) }
  it { should respond_to(:data_modyfikacji) }
  it { should respond_to(:initialized_from_esod) }
  it { should respond_to(:netpar_user) }

  # it { should validate_presence_of(:nrid) }
  # it { should validate_numericality_of(:nrid) }
  # it { should validate_uniqueness_of(:nrid) }

  # it { should validate_presence_of(:znak) }
  # it { should validate_uniqueness_of(:znak).case_insensitive }
end
