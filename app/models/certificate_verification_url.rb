# Adres weryfikacji świadectwa w confirmation – zapisywany w kodzie QR (karta plastikowa w NETPAR i zaświadczenie PDF
# w confirmation8, które dostaje go z API: verification_url). JEDNO miejsce budowania adresu.
# Parametry jak w poprzedniej wersji confirmation (formularz /certificates/new wypełnia się nimi): numer bez prefiksu,
# daty RRRR-MM-DD, brak daty ważności – pusty parametr.
# Adres formularza: secrets.yml confirmation_search_url (np. serwer testowy), domyślnie produkcja.
class CertificateVerificationUrl
  DEFAULT_SEARCH_URL = 'https://confirmation.uke.gov.pl/certificates/new'

  def self.build(number_prefix:, number:, date_of_issue:, valid_thru:, name:, given_names:, birth_date:)
    prefix = number_prefix.to_s
    number = number.to_s.strip
    number = number[prefix.length..-1] if prefix.present? && number.start_with?(prefix)
    "#{search_url}?" + URI.encode_www_form(
      number_prefix: prefix, number: number, date_of_issue: date_of_issue.to_s, valid_thru: valid_thru.to_s,
      name: name.to_s, given_names: given_names.to_s, birth_date: birth_date.to_s)
  end

  def self.search_url
    Rails.application.secrets.confirmation_search_url.presence || DEFAULT_SEARCH_URL
  end
end
