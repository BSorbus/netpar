# Dane świadectwa do nadruku na karcie plastikowej (atrybuty CertificateCardTemplateField::ATTRIBUTES) – ze świadectwa
# albo przykładowe (podgląd układu wzoru).
# Zdjęcie (photo_document): 1) z wniosku z aplikacji Egzaminy (face_image_blob_path – NETPAR kopiuje plik do załączników osoby
# egzaminowanej), 2) gdy wniosek go nie ma – plik graficzny (PNG/JPEG) w załącznikach osoby egzaminowanej z frazą
# „zdjęcie na kartę” w nazwie (pracownik wgrywa go ręcznie; porównanie bez wielkości liter i polskich znaków, „_”, „-”, „.” jak
# spacja, fraza może być częścią nazwy, np. „Kowalski Jan - zdjęcie na kartę.jpg”; kilka – ostatnio wgrany). Bez zdjęcia
# karta nie jest drukowana (CertificateCardTemplate.card_plan – „brak zdjęcia”).
# Kod QR: Certificate#qr_code_url (<confirmation>/qrc/<kod>). Świadectwo bez kodu – karta bez QR (zamiast niedziałającego).
class CertificateCardData
  SAMPLE_VERIFICATION_CODE = '7KD3M9QX2PNAHT5V' # podgląd wzoru – nie zapisywany
  IMAGE_TYPES = %w(image/png image/jpeg image/jpg)
  IMAGE_FILE = /\.(png|jpe?g)\z/i
  CARD_PHOTO_PHRASE = 'zdjecie na karte' # po normalizacji nazwy pliku (card_photo_name?)

  attr_reader :values

  def initialize(values, photo = nil)
    @values = values
    @photo = photo
  end

  def self.from_certificate(certificate)
    customer = certificate.customer
    division = certificate.division
    place = certificate.user && certificate.user.department ? certificate.user.department.address_city.to_s : ''
    birth_date = customer.birth_date.present? ? customer.birth_date.strftime('%d.%m.%Y') : ''
    issued = certificate.date_of_issue.present? ? certificate.date_of_issue.strftime('%d.%m.%Y') : ''
    new({ 'surname' => customer.name.to_s, 'given_names' => customer.given_names.to_s, # jak w danych osoby (wielkość liter – pole wzoru)
          'full_name' => "#{customer.given_names} #{customer.name.to_s.mb_chars.upcase}",
          'birth_date' => birth_date, 'birth_place' => customer.birth_place.to_s,
          'birth_date_and_place' => customer.birth_date_and_place.to_s,
          'number' => certificate.number.to_s, 'date_of_issue' => issued, 'place_of_issue' => place,
          'place_and_date_of_issue' => "#{place} #{issued}".strip,
          'valid_thru' => certificate.valid_thru.present? ? certificate.valid_thru.strftime('%d.%m.%Y') : '',
          'division_card_text' => card_text(division),
          'qr_code' => certificate.qr_code_url.to_s },
        photo_for(certificate))
  end

  # Podgląd układu: przykładowe dane (długie nazwisko – sprawdzenie dopasowania tekstu), bez zdjęcia (ramka zastępcza).
  def self.sample(division)
    today = Time.zone.today
    new({ 'surname' => 'Kowalski-Nowakowski', 'given_names' => 'Jan Maria',
          'full_name' => 'Jan Maria KOWALSKI-NOWAKOWSKI', 'birth_date' => '06.07.1969', 'birth_place' => 'Więcbork',
          'birth_date_and_place' => '06.07.1969 Więcbork', 'number' => "#{division.number_prefix}12345",
          'date_of_issue' => today.strftime('%d.%m.%Y'), 'place_of_issue' => 'Warszawa',
          'place_and_date_of_issue' => "Warszawa #{today.strftime('%d.%m.%Y')}",
          'valid_thru' => (today + 5.years).strftime('%d.%m.%Y'),
          'division_card_text' => card_text(division),
          'qr_code' => Certificate.qr_code_url_for(SAMPLE_VERIFICATION_CODE) })
  end

  # Rodzaj świadectwa na karcie: tekst z typu świadectwa (card_print_text – PL, EN albo oba), a gdy pusty – nazwa PL.
  def self.card_text(division)
    division.card_print_text.presence || division.name.to_s
  end

  # Dokument ze zdjęciem na kartę (bez wczytywania pliku) albo nil – wtedy karta nie jest drukowana.
  def self.photo_document(certificate)
    proposal_photo(certificate) || card_photo_attachment(certificate)
  end

  def self.photo_for(certificate)
    document = photo_document(certificate)
    document.fileattach.read if document
  end

  # Plik graficzny z frazą „zdjęcie na kartę” w nazwie wśród załączników osoby egzaminowanej (ostatnio wgrany).
  def self.card_photo_attachment(certificate)
    examination = certificate.examination
    return unless examination
    examination.documents.select { |d| image?(d) && card_photo_name?(d.fileattach_filename) }.max_by { |d| [d.created_at, d.id] }
  end

  def self.image?(document)
    IMAGE_TYPES.include?(document.fileattach_content_type.to_s) || document.fileattach_filename.to_s =~ IMAGE_FILE
  end

  # „Zdjęcie na kartę” w nazwie pliku: bez rozszerzenia, po zdekodowaniu %XX (kopie z adresów), bez polskich znaków
  # i wielkości liter, z „_”, „-”, „.” i wielokrotnymi spacjami jako jedną spacją.
  def self.card_photo_name?(filename)
    name = filename.to_s
    name = CGI.unescape(name) if name.include?('%')
    name = File.basename(name, File.extname(name))
    name = I18n.transliterate(name.mb_chars.normalize(:c).to_s).downcase.gsub(/[\s_.\-]+/, ' ')
    name.include?(CARD_PHOTO_PHRASE)
  end

  def self.proposal_photo(certificate)
    examination = certificate.examination
    proposal = examination && examination.proposal
    return unless proposal && proposal.face_image_blob_path.present?
    filename = File.basename(URI.parse(proposal.face_image_blob_path).path) # jak Examination#file_to_documents_attach
    examination.documents.detect { |d| d.fileattach_filename == filename }
  rescue URI::InvalidURIError
    nil
  end

  def text(attribute)
    values[attribute].to_s
  end

  # Zdjęcie (dane pliku) albo nil.
  def photo
    @photo
  end
end
