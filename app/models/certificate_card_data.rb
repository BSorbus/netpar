# Dane świadectwa do nadruku na karcie plastikowej (atrybuty CertificateCardTemplateField::ATTRIBUTES) – ze świadectwa
# albo przykładowe (podgląd układu wzoru).
# Zdjęcie: z wniosku z aplikacji Egzaminy (załącznik osoby egzaminowanej o nazwie pliku z face_image_blob_path wniosku),
# a gdy go brak – załącznik świadectwa „face.png/jpg/jpeg” (dodany przez urzędnika).
class CertificateCardData
  FACE_FILE = /\Aface\.(png|jpe?g)\z/i

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
    new({ 'full_name' => "#{customer.given_names} #{customer.name.to_s.mb_chars.upcase}",
          'birth_date' => birth_date, 'birth_place' => customer.birth_place.to_s,
          'birth_date_and_place' => customer.birth_date_and_place.to_s,
          'number' => certificate.number.to_s, 'date_of_issue' => issued, 'place_of_issue' => place,
          'place_and_date_of_issue' => "#{place} #{issued}".strip,
          'valid_thru' => certificate.valid_thru.present? ? certificate.valid_thru.strftime('%d.%m.%Y') : '',
          'division_card_text' => card_text(division) },
        photo_for(certificate))
  end

  # Podgląd układu: przykładowe dane (długie nazwisko – sprawdzenie dopasowania tekstu), bez zdjęcia (ramka zastępcza).
  def self.sample(division)
    today = Time.zone.today
    new({ 'full_name' => 'Jan Maria KOWALSKI-NOWAKOWSKI', 'birth_date' => '06.07.1969', 'birth_place' => 'Więcbork',
          'birth_date_and_place' => '06.07.1969 Więcbork', 'number' => "#{division.number_prefix}12345",
          'date_of_issue' => today.strftime('%d.%m.%Y'), 'place_of_issue' => 'Warszawa',
          'place_and_date_of_issue' => "Warszawa #{today.strftime('%d.%m.%Y')}",
          'valid_thru' => (today + 5.years).strftime('%d.%m.%Y'),
          'division_card_text' => card_text(division) })
  end

  # Rodzaj świadectwa na karcie: tekst z typu świadectwa (card_print_text – PL, EN albo oba), a gdy pusty – nazwa PL.
  def self.card_text(division)
    division.card_print_text.presence || division.name.to_s
  end

  def self.photo_for(certificate)
    document = proposal_photo(certificate) || certificate.documents.detect { |d| d.fileattach_filename.to_s =~ FACE_FILE }
    document.fileattach.read if document
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
