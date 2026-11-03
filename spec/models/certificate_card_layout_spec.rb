require 'rails_helper'

# Układ nadruku na karcie (pola wzoru), dane do nadruku i PDF karty (CR80, awers + rewers).
RSpec.describe 'Karta plastikowa – układ, dane i wydruk', type: :model do
  include ApiHelpers # create_division, create_certificate

  let(:division) { create_division(category: 'M', short_name: 'SRC', name: 'świadectwo SRC', number_prefix: 'MS-', english_name: 'SRC certificate') }

  def file(name, type = 'image/png')
    Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', name), type)
  end

  let(:template) do
    CertificateCardTemplate.create!(division: division, name: 'Karta', valid_from: Date.new(2020, 1, 1),
                                    card_front: file('card_ok.png'), card_back: file('card_ok_600dpi.jpg', 'image/jpeg'))
  end

  def field(attributes = {})
    template.fields.build({ attribute_name: 'full_name', side: 'front', x: 5, y: 5, width: 40, height: 6, font_size: 10 }.merge(attributes))
  end

  describe 'pole układu' do
    it 'musi mieścić się na karcie 85,6 × 54 mm, z atrybutem z katalogu i czcionką 4–40 pt' do
      expect(field).to be_valid
      expect(field(x: 50, width: 40)).not_to be_valid
      expect(field(y: 50, height: 6).tap(&:valid?).errors[:height].join).to include 'wychodzi poza kartę'
      expect(field(attribute_name: 'pesel')).not_to be_valid
      expect(field(font_size: 2)).not_to be_valid
      expect(field(side: 'middle')).not_to be_valid
    end

    it 'zapis z edytora: niezaznaczone nowe pola pomijane, niezaznaczone zapisane – usuwane' do
      template.update!(fields_attributes: [{ attribute_name: 'full_name', enabled: '1', side: 'front', x: 5, y: 5, width: 40, height: 6, font_size: 10 },
                                           { attribute_name: 'number', enabled: '0', side: 'front', x: 5, y: 15, width: 30, height: 5, font_size: 10 }])
      expect(template.fields.reload.map(&:attribute_name)).to eq ['full_name']

      saved = template.fields.first
      template.update!(fields_attributes: [{ id: saved.id, enabled: '0', _destroy: '1' }])
      expect(template.fields.reload).to be_empty
    end
  end

  describe 'wielkość liter pola' do
    it 'oryginał (domyślnie), WIELKIE, małe, Pierwsza Wielka w każdym słowie – z polskimi znakami' do
      expect(field.letter_case).to eq 'original'
      expect(field.formatted('Bogdan JARZĄB')).to eq 'Bogdan JARZĄB'
      expect(field(letter_case: 'upper').formatted('Łukasz żółty')).to eq 'ŁUKASZ ŻÓŁTY'
      expect(field(letter_case: 'lower').formatted('ŁUKASZ ŻÓŁTY')).to eq 'łukasz żółty'
      expect(field(letter_case: 'capitalize').formatted('JAN MARIA KOWALSKI-NOWAK')).to eq 'Jan Maria Kowalski-Nowak'
      expect(field(letter_case: 'capitalize').formatted("BOGDAN o'CONNOR")).to eq "Bogdan O'Connor"
      expect(field(letter_case: 'mixed')).not_to be_valid
    end

    it 'zapis z edytora układu' do
      template.update!(fields_attributes: [{ attribute_name: 'full_name', enabled: '1', side: 'front', x: 5, y: 5, width: 40, height: 6,
                                             font_size: 10, letter_case: 'capitalize' }])
      expect(template.fields.reload.first.letter_case).to eq 'capitalize'
    end
  end

  describe 'dane do nadruku' do
    it 'nazwisko i imiona – osobne atrybuty z danych osoby (bez zmiany wielkości liter), obok „Imię i NAZWISKO”' do
      customer = Customer.new(name: 'Jarząb', given_names: 'Bogdan Jan', birth_date: Date.new(1969, 7, 6))
      certificate = Certificate.new(division: division, customer: customer, number: 'MS-1', date_of_issue: Date.new(2026, 12, 2))
      allow(CertificateCardData).to receive(:photo_for).and_return(nil)
      data = CertificateCardData.from_certificate(certificate)
      expect([data.text('surname'), data.text('given_names'), data.text('full_name')]).to eq ['Jarząb', 'Bogdan Jan', 'Bogdan Jan JARZĄB']
      expect(field(attribute_name: 'surname', letter_case: 'upper').formatted(data.text('surname'))).to eq 'JARZĄB'
      expect(CertificateCardTemplateField::ATTRIBUTES.first(3)).to eq %w(surname given_names full_name)
    end

    it 'źródło wartości każdego atrybutu – model (nazwa z tłumaczeń) i kolumna' do
      expect(field(attribute_name: 'given_names').source).to eq '(Klient).given_names'
      expect(field(attribute_name: 'date_of_issue').source).to eq '(Świadectwo).date_of_issue'
      expect(field(attribute_name: 'division_card_text').source).to eq '(Typ Świadectwa).card_print_text, gdy puste – (Typ Świadectwa).name'
      expect(CertificateCardTemplateField::ATTRIBUTES.map { |name| field(attribute_name: name).source }).to all(be_present)
    end

    it 'rodzaj świadectwa: tekst na kartę z typu świadectwa, a gdy pusty – nazwa PL' do
      expect(CertificateCardData.sample(division).text('division_card_text')).to eq 'świadectwo SRC'
      division.update_column(:card_print_text, 'SRC – Short Range Certificate')
      expect(CertificateCardData.sample(division.reload).text('division_card_text')).to eq 'SRC – Short Range Certificate'
    end

    it 'ze świadectwa: imię i NAZWISKO, daty jak na świadectwie' do
      certificate = create_certificate(division: division, number: 'MS-777', date_of_issue: Date.new(2026, 11, 20), valid_thru: Date.new(2031, 11, 20),
                                       customer: { name: 'Kowalski', given_names: 'Jan', birth_date: Date.new(1969, 7, 6), birth_place: 'Więcbork' })
      data = CertificateCardData.from_certificate(certificate)
      expect(%w(full_name birth_date_and_place number date_of_issue valid_thru).map { |a| data.text(a) })
        .to eq ['Jan KOWALSKI', '06.07.1969 Więcbork', 'MS-777', '20.11.2026', '20.11.2031']
    end

    it 'nazwa pliku „zdjęcie na kartę”: bez wielkości liter i polskich znaków, „_ - .” jak spacja, także jako część nazwy' do
      matching = ['zdjęcie na kartę.jpg', 'zdjecie na karte.JPG', 'zdjecie_na_karte.png', 'Zdjęcie-na-kartę.jpeg',
                  'Kowalski Jan - zdjęcie na kartę.jpg', 'Zdj%C4%99cie%20na%20kart%C4%99.jpg', "Zdje\u0328cie na karte\u0328.jpg"]
      expect(matching.map { |name| CertificateCardData.card_photo_name?(name) }).to all(be true)
      expect(['zdjecie.jpg', 'skan wniosku.jpg', 'na karte zdjecie.jpg'].map { |name| CertificateCardData.card_photo_name?(name) }).to all(be false)
    end

    it 'kod QR: krótki adres /qrc/ z kodem świadectwa – bez danych osobowych; ten sam kod przy każdym wydruku' do
      certificate = create_certificate(division: division, number: 'MS-00777', date_of_issue: Date.new(2026, 11, 20), valid_thru: Date.new(2031, 11, 20),
                                       customer: { name: 'Jarząb', given_names: 'Bogdan Jan', birth_date: Date.new(1969, 7, 6) })
      allow(CertificateCardData).to receive(:photo_for).and_return(nil)
      code = certificate.verification_code
      expect(code).to match Certificate::VERIFICATION_CODE_FORMAT # nadany przy utworzeniu świadectwa

      url = CertificateCardData.from_certificate(certificate).text('qr_code')
      expect(url).to eq "https://confirmation.uke.gov.pl/qrc/#{code}"
      expect(url).not_to include 'Jarz', '1969', '00777'
      expect(CertificateCardData.from_certificate(Certificate.find(certificate.id)).text('qr_code')).to eq url # ponowny wydruk – ten sam kod

      allow(Rails.application.secrets).to receive(:confirmation_search_url).and_return('http://localhost:3000/certificates/new')
      expect(CertificateCardData.sample(division).text('qr_code')).to eq 'http://localhost:3000/qrc/7KD3M9QX2PNAHT5V' # podgląd – kod przykładowy
      expect(field(attribute_name: 'qr_code')).to be_image
    end

    it 'kod weryfikacji: nadawany przy utworzeniu świadectwa, 16 znaków bez I, L, O, U, unikalny (przy kolizji – nowe losowanie)' do
      expect(CertificateCardData::SAMPLE_VERIFICATION_CODE).to match Certificate::VERIFICATION_CODE_FORMAT # podgląd – kod poprawny
      codes = Array.new(200) { Certificate.generate_verification_code }
      expect(codes).to all(match Certificate::VERIFICATION_CODE_FORMAT)
      expect(codes.join).not_to match(/[ILOU]/)
      expect(codes.uniq.size).to eq 200

      taken = create_certificate(division: division, number: 'MS-00778')
      allow(Certificate).to receive(:generate_verification_code).and_return(taken.verification_code, 'BBBBBBBBBBBBBBBB')
      expect(create_certificate(division: division, number: 'MS-00779').reload.verification_code).to eq 'BBBBBBBBBBBBBBBB'
      expect(taken.reload.verification_code).not_to eq 'BBBBBBBBBBBBBBBB' # istniejący kod bez zmian
    end

    it 'kod weryfikacji: nowy kod tylko przez administratora z konsoli – stary nieważny, wpis w historii bez kodu' do
      certificate = create_certificate(division: division, number: 'MS-00780')
      old_code = certificate.verification_code
      admin = FactoryBot.create(:user)
      expect { certificate.regenerate_verification_code!(nil) }.to raise_error(ArgumentError)

      new_code = certificate.regenerate_verification_code!(admin)
      expect(new_code).to match(Certificate::VERIFICATION_CODE_FORMAT).and(satisfy { |c| c != old_code })
      expect(certificate.reload.verification_code).to eq new_code
      expect(Certificate.find_by(verification_code: old_code)).to be_nil
      work = certificate.works.last
      expect([work.action, work.user, work.action_name]).to eq ['regenerate_verification_code', admin, 'nadał nowy kod weryfikacji (QR karty)']
      expect(work.parameters).not_to include new_code, old_code
    end

    it 'świadectwo bez kodu – karta bez QR (zamiast niedziałającego kodu)' do
      certificate = create_certificate(division: division, number: 'MS-00781')
      certificate.update_column(:verification_code, nil)
      allow(CertificateCardData).to receive(:photo_for).and_return(nil)
      expect(CertificateCardData.from_certificate(certificate.reload).text('qr_code')).to eq ''
    end

    it 'zdjęcie z wniosku; bez niego – plik graficzny osoby egzaminowanej z „zdjęcie na kartę” w nazwie (najnowszy)' do
      certificate = create_certificate(division: division, number: 'MS-778', date_of_issue: Date.new(2026, 11, 20))
      ProposalStatus.new(name: 'Zaakceptowane').tap { |st| st.id = 2; st.save!(validate: false) }
      exam = FactoryBot.build(:exam, category: 'M', esod_category: 47, max_examinations: 10, date_exam: Date.today + 30).tap { |e| e.save!(validate: false) }
      new_proposal = lambda do |face_path|
        Proposal.new(exam: exam, division: division, category: 'M', multi_app_identifier: SecureRandom.uuid, proposal_status_id: 2,
                     face_image_blob_path: face_path).tap { |p| p.save!(validate: false) }
      end

      # wniosek ze zdjęciem: NETPAR skopiował je do załączników osoby egzaminowanej – to jest zdjęcie na kartę
      examination = Examination.new(certificate: certificate, proposal: new_proposal.call('/rails/active_storage/blobs/redirect/abc/zdjecie_kandydata.jpg'),
                                    division: division).tap { |e| e.save!(validate: false) }
      from_proposal = Document.create!(documentable: examination, fileattach: file('card_ok_600dpi.jpg', 'image/jpeg'),
                                       fileattach_filename: 'zdjecie_kandydata.jpg', created_at: 3.days.ago)
      marked = Document.create!(documentable: examination, fileattach: file('card_square.png'), fileattach_filename: 'Kowalski Jan - zdjęcie na kartę.png')
      expect(CertificateCardData.photo_for(certificate.reload)).to eq from_proposal.fileattach.read # zdjęcie z wniosku ma pierwszeństwo

      # wniosek bez zdjęcia: plik z „zdjęcie na kartę” w nazwie; inne obrazy (np. skany) i pliki nie-graficzne – pomijane
      examination.update_column(:proposal_id, new_proposal.call(nil).id)
      Document.create!(documentable: examination, fileattach: file('card_ok.png'), fileattach_filename: 'skan wniosku.png', created_at: 1.minute.from_now)
      Document.create!(documentable: examination, fileattach: file('card_text.txt', 'text/plain'), fileattach_filename: 'zdjecie_na_karte.txt')
      expect(CertificateCardData.photo_document(certificate.reload)).to eq marked
      expect(CertificateCardData.photo_for(certificate.reload)).to eq marked.fileattach.read

      # kilka oznaczonych – ostatnio wgrany
      newer = Document.create!(documentable: examination, fileattach: file('card_ok.png'), fileattach_filename: 'zdjecie_na_karte.png', created_at: 2.minutes.from_now)
      expect(CertificateCardData.photo_document(certificate.reload)).to eq newer

      # bez oznaczonego pliku – brak zdjęcia (ostatni obraz nie wystarcza)
      examination.documents.where(id: [marked.id, newer.id]).delete_all
      expect(CertificateCardData.photo_document(certificate.reload)).to be_nil

      # bez osoby egzaminowanej i bez oznaczonych plików – brak zdjęcia (obraz bez frazy, np. „face.png”, nie wystarcza)
      other = create_certificate(division: division, number: 'MS-779', date_of_issue: Date.new(2026, 11, 20))
      Document.create!(documentable: other, fileattach: file('card_ok.png'), fileattach_filename: 'face.png')
      expect(CertificateCardData.photo_for(other)).to be_nil
    end

    it 'kolejność: 1) zgłoszenie, 2) załącznik świadectwa, 3) osoby egzaminowanej, 4) klienta – w 2–4 tylko obraz z „zdjęcie na kartę”' do
      certificate = create_certificate(division: division, number: 'MS-780', date_of_issue: Date.new(2026, 11, 20))
      examination = Examination.new(certificate: certificate, customer: certificate.customer, division: division).tap { |e| e.save!(validate: false) }
      customer = certificate.customer
      mark = ->(owner, name, at = Time.now) { Document.create!(documentable: owner, fileattach: file('card_ok.png'), fileattach_filename: name, created_at: at) }

      # same pliki bez frazy (skany, zdjęcia bez oznaczenia, PDF z frazą) – brak zdjęcia
      mark.(certificate, 'skan swiadectwa.png'); mark.(examination, 'wniosek.jpg'); mark.(customer, 'dowod.png')
      Document.create!(documentable: certificate, fileattach: file('card_text.txt', 'text/plain'), fileattach_filename: 'zdjecie na karte.pdf')
      expect(CertificateCardData.photo_document(certificate.reload)).to be_nil

      from_customer = mark.(customer, 'zdjęcie_na_kartę.png')
      expect(CertificateCardData.photo_document(certificate.reload)).to eq from_customer           # 4) klient

      from_examination = mark.(examination, 'Kowalski - zdjecie-na-karte.jpg', 1.day.ago)
      expect(CertificateCardData.photo_document(certificate.reload)).to eq from_examination        # 3) osoba egzaminowana przed klientem

      from_certificate = mark.(certificate, 'ZDJĘCIE NA KARTĘ.png', 2.days.ago)
      expect(CertificateCardData.photo_document(certificate.reload)).to eq from_certificate        # 2) świadectwo przed osobą egzaminowaną

      allow(CertificateCardData).to receive(:proposal_photo).and_return(:ze_zgloszenia)
      expect(CertificateCardData.photo_document(certificate.reload)).to eq :ze_zgloszenia          # 1) zgłoszenie przed wszystkim
    end
  end

  describe 'PDF karty' do
    it 'karta CR80 (85,6 × 54 mm), dwie strony na świadectwo – awers i rewers; ze zdjęciem i bez' do
      field(attribute_name: 'full_name').save!
      field(attribute_name: 'number', side: 'back', y: 40).save!
      field(attribute_name: 'photo', x: 60, y: 10, width: 20, height: 25).save!
      with_photo = CertificateCardData.new({ 'full_name' => 'Jan Maria KOWALSKI-NOWAKOWSKI-WIŚNIEWSKI', 'number' => 'MS-1' },
                                           File.binread(Rails.root.join('spec', 'fixtures', 'files', 'card_ok_600dpi.jpg')))
      pdf = PdfCertificateCard.new([[with_photo, template], [CertificateCardData.sample(division), template.reload]], 'test', 'Karty').render

      expect(pdf).to start_with '%PDF'
      expect(pdf.scan(%r{/Type /Page\b}).size).to eq 4
      width, height = pdf[%r{/MediaBox \[0 0 ([\d.]+) ([\d.]+)\]}, 1].to_f, pdf[%r{/MediaBox \[0 0 ([\d.]+) ([\d.]+)\]}, 2].to_f
      expect([width.round(1), height.round(1)]).to eq [242.6, 153.1]
    end

    it 'tło karty osadzane najwyżej w 600 dpi drukarki (2022 × 1276 px); mniejsza grafika – bez zmian' do
      # wymiary obrazów osadzonych w PDF
      sizes = ->(pdf) { pdf.scan(%r{/Subtype /Image[^>]*?/Width (\d+)\s*/Height (\d+)}m).map { |w, h| [w.to_i, h.to_i] } }
      small_template = template # wzór od 2020 – przed wzorem od 2030 (okresy nie mogą się nakładać)
      big = Rails.root.join('tmp', "card_1300dpi_#{SecureRandom.hex(4)}.png").to_s
      begin
        MiniMagick::Tool::Convert.new { |c| c.size '4370x2754'; c << 'xc:#1B3C8F'; c << big }
        big_template = CertificateCardTemplate.create!(division: division, name: 'Karta 1300 dpi', valid_from: Date.new(2030, 1, 1),
                                                       card_front: Rack::Test::UploadedFile.new(big, 'image/png'), card_back: file('card_ok.png'))
        pdf = PdfCertificateCard.new([[CertificateCardData.sample(division), big_template]], 'test', 'Karty').render
        expect(PdfCertificateCard::BACKGROUND_MAX).to eq [2022, 1276]
        expect(sizes.call(pdf).first).to eq [2022, 1274] # 4370 × 2754 zmniejszone z zachowaniem proporcji
      ensure
        File.delete(big) if File.exist?(big)
      end

      small = PdfCertificateCard.new([[CertificateCardData.sample(division), small_template.reload]], 'test', 'Karty').render
      original = MiniMagick::Image.open(Rails.root.join('spec', 'fixtures', 'files', 'card_ok.png').to_s)
      expect(sizes.call(small).first).to eq [original.width, original.height]
    end

    it 'kod QR – kwadrat wpisany w obszar pola, na białym tle; bez adresu – pomijany' do
      field(attribute_name: 'qr_code', side: 'back', x: 60, y: 25, width: 22, height: 26).save!
      expect(template.reload.fields.first).to be_qr_code
      document = PdfCertificateCard.new([[CertificateCardData.sample(division), template]], 'test', 'Karty')
      expect(document.render).to start_with '%PDF'
      expect(PdfCertificateCard.new([[CertificateCardData.new({}), template]], 'test', 'Karty').render).to start_with '%PDF'
    end
  end
end
