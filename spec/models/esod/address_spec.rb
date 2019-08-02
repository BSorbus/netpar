require 'rails_helper'

RSpec.describe Esod::Address, type: :model do
  let(:esod_address) { FactoryBot.build :esod_address }
  subject { esod_address }

  it { should respond_to(:nrid) }
  it { should respond_to(:miasto) }
  it { should respond_to(:kod_pocztowy) }
  it { should respond_to(:ulica) }
  it { should respond_to(:numer_lokalu) }
  it { should respond_to(:numer_budynku) }
  it { should respond_to(:skrytka_epuap) }
  it { should respond_to(:panstwo) }
  it { should respond_to(:email) }
  it { should respond_to(:typ) }
  it { should respond_to(:initialized_from_esod) }
  it { should respond_to(:netpar_user) }
  it { should respond_to(:customer_id) }
end
