require 'rails_helper'

# Stawki opłat wersjonowane w czasie: nowa otwarta stawka zamyka poprzednią otwartą (dzień przed swoim „Od”).
RSpec.describe ExamFee, type: :model do
  include ApiHelpers # create_division

  let(:division) { create_division(category: 'M', short_name: 'SRC', name: 'świadectwo SRC', number_prefix: 'MS-') }
  let(:user) { FactoryBot.create(:user) }

  def fee(attributes = {})
    ExamFee.new({ division: division, esod_category: 41, price: 100, user: user }.merge(attributes))
  end

  it 'nowa otwarta stawka zamyka poprzednią otwartą dzień przed swoim „Od” – z wpisem w historii' do
    old = fee(valid_from: Date.new(2025, 1, 1)).tap(&:save!)
    new_fee = fee(price: 150, valid_from: Date.new(2027, 1, 1))

    expect(new_fee.save).to be true
    expect(old.reload.valid_to).to eq Date.new(2026, 12, 31)
    expect(new_fee.reload.valid_to).to be_nil
    expect(JSON.parse(old.works.last.parameters)).to include('valid_to' => [nil, '2026-12-31'])
    expect(old.works.last.user).to eq user
    expect(ExamFee.where(division: division, esod_category: 41).for_date(Date.new(2026, 6, 1)).first).to eq old
    expect(ExamFee.where(division: division, esod_category: 41).for_date(Date.new(2027, 6, 1)).first).to eq new_fee
  end

  it 'zamyka też stawkę otwartą bez „Od” (od zawsze) i nie rusza innego rodzaju wniosku' do
    always = fee(valid_from: nil).tap(&:save!)
    correction = fee(esod_category: 42, price: 50, valid_from: Date.new(2025, 1, 1)).tap(&:save!)

    fee(price: 150, valid_from: Date.new(2027, 1, 1)).save!
    expect(always.reload.valid_to).to eq Date.new(2026, 12, 31)
    expect(correction.reload.valid_to).to be_nil
  end

  it 'nadal odrzuca nakładające się okresy: stawkę w środku zamkniętego okresu i otwartą wcześniejszą niż istniejąca otwarta' do
    fee(valid_from: Date.new(2025, 1, 1), valid_to: Date.new(2026, 12, 31)).save!
    current = fee(price: 150, valid_from: Date.new(2027, 1, 1)).tap(&:save!)

    inside = fee(price: 120, valid_from: Date.new(2026, 1, 1), valid_to: Date.new(2026, 6, 30))
    expect(inside).not_to be_valid
    expect(inside.errors[:base]).to include 'Zakres dat nakłada się na istniejący wpis'

    earlier_open = fee(price: 130, valid_from: Date.new(2026, 6, 1))
    expect(earlier_open).not_to be_valid
    expect(current.reload.valid_to).to be_nil
  end
end
