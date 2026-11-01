require 'rails_helper'

# Wzory kart świadectw – wersjonowane w czasie: świadectwo drukuje się wg wzoru obowiązującego w dniu wydania.
RSpec.describe CertificateCardTemplate, type: :model do
  include ApiHelpers # create_division, create_certificate

  let(:division) { create_division(category: 'M', short_name: 'SRC', name: 'świadectwo SRC', number_prefix: 'MS-') }

  def card(name, type = 'image/png')
    Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', name), type)
  end

  def template(attributes = {})
    CertificateCardTemplate.new({ division: division, name: 'Wzór', valid_from: Date.new(2026, 12, 1),
                                  card_front: card('card_ok.png'), card_back: card('card_ok_600dpi.jpg', 'image/jpeg') }.merge(attributes))
  end

  def certificate(date)
    create_certificate(division: division, number: "MS-#{date.strftime('%Y%m%d')}", date_of_issue: date)
  end

  it 'nowy wzór zamyka poprzedni otwarty (dzień przed „Od”), z wpisem w historii; wybór wzoru wg daty wydania świadectwa' do
    a = template(name: 'A', valid_from: Date.new(2026, 12, 1)).tap(&:save!)
    b = template(name: 'B', valid_from: Date.new(2028, 7, 1)).tap(&:save!)
    c = template(name: 'C', valid_from: Date.new(2031, 3, 1)).tap(&:save!)

    expect([a.reload.valid_to, b.reload.valid_to, c.reload.valid_to]).to eq [Date.new(2028, 6, 30), Date.new(2031, 2, 28), nil]
    expect(JSON.parse(a.works.last.parameters)).to include('valid_to' => [nil, '2028-06-30'])

    expect(CertificateCardTemplate.for_certificate(Certificate.new(division: division, date_of_issue: Date.new(2025, 10, 15)))).to be_nil
    expect(CertificateCardTemplate.for_certificate(Certificate.new(division: division, date_of_issue: Date.new(2027, 5, 10)))).to eq a
    expect(CertificateCardTemplate.for_certificate(Certificate.new(division: division, date_of_issue: Date.new(2028, 6, 30)))).to eq a
    expect(CertificateCardTemplate.for_certificate(Certificate.new(division: division, date_of_issue: Date.new(2028, 7, 1)))).to eq b
    expect(CertificateCardTemplate.for_certificate(Certificate.new(division: division, date_of_issue: Date.new(2031, 4, 20)))).to eq c
  end

  it 'okresy wzorów jednego rodzaju nie mogą się nakładać' do
    template(name: 'A', valid_from: Date.new(2026, 12, 1), valid_to: Date.new(2027, 12, 31)).save!
    later = template(name: 'B', valid_from: Date.new(2028, 1, 1)).tap(&:save!)

    inside = template(name: 'X', valid_from: Date.new(2027, 6, 1), valid_to: Date.new(2027, 6, 30))
    expect(inside).not_to be_valid
    expect(inside.errors[:base].join).to include 'nakłada się na wzór „A”'

    earlier_open = template(name: 'Y', valid_from: Date.new(2026, 1, 1))
    expect(earlier_open).not_to be_valid # otwarty od 2026 – nakłada się na A i B
    expect(later.reload.valid_to).to be_nil
  end

  it 'nie można dodać wzoru, pod który podpadłyby już wydane świadectwa – podpowiedź najwcześniejszej daty' do
    b = template(name: 'B', valid_from: Date.new(2028, 7, 1)).tap(&:save!)
    certificate(Date.new(2029, 1, 10))

    too_early = template(name: 'D', valid_from: Date.new(2029, 1, 1))
    expect(too_early).not_to be_valid
    expect(too_early.errors[:valid_from].join).to include 'wydano już 1 świadectw', 'najwcześniej od 2029-01-11'

    template(name: 'D', valid_from: Date.new(2029, 1, 11)).save!
    expect(b.reload.valid_to).to eq Date.new(2029, 1, 10)
  end

  it 'zmiana rodzaju lub okresu nie może zmienić wzoru wydanych świadectw; podmiana grafiki – dozwolona' do
    a = template(name: 'A', valid_from: Date.new(2026, 12, 1)).tap(&:save!)
    certificate(Date.new(2027, 3, 1))

    a.valid_from = Date.new(2027, 4, 1)
    expect(a).not_to be_valid
    expect(a.errors[:base].join).to include 'zmieniłaby wzór wydanych już świadectw'

    a.reload.card_front = card('card_ok_600dpi.jpg', 'image/jpeg')
    expect(a.save).to be true
    expect(a.reload.card_front_filename).to eq 'card_ok_600dpi.jpg'
  end

  it 'wzoru, wg którego drukują się wydane świadectwa, nie można usunąć' do
    used = template(name: 'A', valid_from: Date.new(2026, 12, 1)).tap(&:save!)
    certificate(Date.new(2027, 3, 1))
    expect(used.destroy).to be false
    expect(used.errors[:base].join).to include 'drukuje się 1 wydanych świadectw'

    unused = template(name: 'B', valid_from: Date.new(2030, 1, 1)).tap(&:save!)
    expect(unused.destroy).to be_truthy
  end

  it 'wydruk kart: tylko świadectwa ze wzorem na dzień wydania, pozostałe – pominięte; ten sam wzór – jeden obiekt' do
    old_cert = certificate(Date.new(2026, 11, 30))
    a = template(name: 'A', valid_from: Date.new(2026, 12, 1)).tap(&:save!)
    first = certificate(Date.new(2027, 2, 1))
    second = certificate(Date.new(2027, 3, 1))

    items, skipped = CertificateCardTemplate.card_items([old_cert, first, second])
    expect(items.map { |data, tpl| [data.text('number'), tpl] }).to eq [[first.number, a], [second.number, a]]
    expect(items.map(&:last).map(&:object_id).uniq.size).to eq 1
    expect(skipped).to eq [old_cert]
  end

  it 'wymaga awersu, rewersu i nazwy; grafika: proporcje karty od 300 dpi, PNG/JPEG' do
    empty = CertificateCardTemplate.new(division: division, valid_from: Date.new(2026, 12, 1))
    expect(empty).not_to be_valid
    expect(empty.errors.keys).to include(:card_front, :card_back, :name)

    bad = template(card_front: card('card_small.png'), card_back: card('card_square.png'))
    expect(bad).not_to be_valid
    expect(bad.errors[:card_front].join).to include 'za mała rozdzielczość: 500 × 316 px'
    expect(bad.errors[:card_back].join).to include 'niewłaściwe proporcje: 1100 × 1100 px'

    text = template(card_front: card('card_text.txt', 'text/plain'))
    expect(text).not_to be_valid
    expect(text.errors[:card_front]).to be_present
  end
end
