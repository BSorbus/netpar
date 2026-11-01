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

  describe 'dane do nadruku' do
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

    it 'zdjęcie: 1) z wniosku, 2) gdy wniosek go nie ma – ostatnio wgrany plik graficzny wśród załączników osoby egzaminowanej' do
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
      Document.create!(documentable: examination, fileattach: file('card_square.png'), fileattach_filename: 'reczny.png')
      expect(CertificateCardData.photo_for(certificate.reload)).to eq from_proposal.fileattach.read

      # wniosek bez zdjęcia: ostatni graficzny załącznik osoby egzaminowanej, dodany ręcznie (PDF/TXT pomijane)
      examination.update_column(:proposal_id, new_proposal.call(nil).id)
      Document.create!(documentable: examination, fileattach: file('card_text.txt', 'text/plain'), fileattach_filename: 'notatka.txt')
      latest = examination.documents.select { |d| d.fileattach_filename =~ /\.(png|jpe?g)\z/ }.max_by(&:created_at)
      expect(latest.fileattach_filename).to eq 'reczny.png'
      expect(CertificateCardData.photo_for(certificate.reload)).to eq latest.fileattach.read

      # bez osoby egzaminowanej – brak zdjęcia (załączniki świadectwa nie są brane)
      other = create_certificate(division: division, number: 'MS-779', date_of_issue: Date.new(2026, 11, 20))
      Document.create!(documentable: other, fileattach: file('card_ok.png'), fileattach_filename: 'face.png')
      expect(CertificateCardData.photo_for(other)).to be_nil
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
  end
end
