require 'rails_helper'

RSpec.describe Esod::Contractor, type: :model do
  let(:esod_contractor) { FactoryGirl.build :esod_contractor }
  subject { esod_contractor }

  it { should respond_to(:nrid) }
  it { should respond_to(:imie) }
  it { should respond_to(:nazwisko) }
  it { should respond_to(:nazwa) }
  it { should respond_to(:drugie_imie) }
  it { should respond_to(:tytul) }
  it { should respond_to(:nip) }
  it { should respond_to(:pesel) }
  it { should respond_to(:rodzaj) }
  it { should respond_to(:initialized_from_esod) }
  it { should respond_to(:netpar_user) }

end
