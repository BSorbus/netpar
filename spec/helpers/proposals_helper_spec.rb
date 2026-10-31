require 'rails_helper'

# Panel „Aplikacja Egzaminy”: szczegóły zdarzeń z historii zgłoszenia – nazwy z NETPAR zamiast identyfikatorów.
RSpec.describe ProposalsHelper, type: :helper do
  include ApiHelpers # create_division
  let!(:status) { ProposalStatus.new(name: 'Zaakceptowane').tap { |s| s.id = 2; s.save!(validate: false) } }
  let!(:division) { create_division(category: 'R', short_name: 'A', name: 'świadectwo klasy A', number_prefix: 'A-') }
  let!(:exam) { FactoryBot.build(:exam, number: '0006/R-TEST/2026', category: 'R').tap { |e| e.save!(validate: false) } }

  it 'wysłanie: sesja i rodzaj z NETPAR' do
    event = { 'kind' => 'submitted', 'data' => { 'exam_id' => exam.id, 'division_id' => division.id } }
    expect(helper.egzaminy_event_details(event)).to eq "sesja: #{exam.reload.number}; rodzaj: A"
  end

  it 'mail: adresat i rodzaj wiadomości po polsku' do
    event = { 'kind' => 'mail', 'data' => { 'to' => 'jan@example.com', 'template' => 'examination_result_n' } }
    expect(helper.egzaminy_event_details(event)).to eq 'do: jan@example.com; wiadomość: wynik egzaminu: negatywny z prawem do poprawki'
  end

  it 'zmiana z NETPAR: nazwa statusu i uzasadnienie' do
    event = { 'kind' => 'netpar_update', 'data' => { 'proposal_status_id' => 2, 'not_approved_comment' => 'Brak opłaty' } }
    expect(helper.egzaminy_event_details(event)).to eq 'status: Zaakceptowane; uzasadnienie: Brak opłaty'
  end

  it 'data z API w formacie NETPAR' do
    expect(helper.egzaminy_time('2026-10-31T21:47:49.238+01:00')).to eq '2026-10-31 21:47:49'
    expect(helper.egzaminy_time(nil)).to eq ''
  end
end
