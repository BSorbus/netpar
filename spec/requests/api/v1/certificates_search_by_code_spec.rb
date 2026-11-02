require 'rails_helper'

# Weryfikacja po kodzie świadectwa (QR karty i zaświadczenia: <confirmation>/qrc/<kod>) – confirmation8.
# Ten sam format odpowiedzi co search; dane aktualne.
RSpec.describe 'API v1 certificates/search_by_code', type: :request do
  let!(:goc) { create_division(category: 'M', short_name: 'GOC', name: 'świadectwo ogólne operatora GMDSS', number_prefix: 'GG-', enabled_in_confirmation: true) }
  let!(:cso) { create_division(category: 'M', short_name: 'CSO', name: 'świadectwo operatora stacji nadbrzeżnej CSO', number_prefix: 'GC-', enabled_in_confirmation: false) }
  let!(:certificate) { create_certificate(division: goc, number: 'GG-05998') }

  def search_by_code(code, headers = api_headers('HTTP_X_REAL_IP' => '203.0.113.5'))
    get '/api/v1/certificates/search_by_code', { code: code }, headers
  end

  it 'wymaga tokenu' do
    get '/api/v1/certificates/search_by_code', code: certificate.verification_code
    expect(response).to have_http_status(:unauthorized)
  end

  it 'zwraca świadectwo w formacie search z aktualnymi danymi i adresem do QR zaświadczenia; zapisuje log' do
    certificate.customer.update_columns(name: 'Nowak') # zmiana nazwiska po wydaniu – wynik z aktualnymi danymi
    expect { search_by_code(certificate.verification_code.downcase) }.to change(ConfirmationLog, :count).by(1) # wielkość liter bez znaczenia

    expect(response).to have_http_status(:ok)
    expect(json.keys).to eq %w(certificates meta)
    found = json['certificates'].first
    expect(found).to include('id' => certificate.id, 'number' => 'GG-05998', 'date_of_issue' => '2018-08-30',
                             'valid_thru' => '2028-08-30', 'category' => 'M',
                             'verification_url' => "https://confirmation.uke.gov.pl/qrc/#{certificate.verification_code}")
    expect(found['division']).to eq('id' => goc.id, 'name' => 'świadectwo ogólne operatora GMDSS', 'english_name' => 'EN GOC',
                                    'short_name' => 'GOC', 'number_prefix' => 'GG-')
    expect(found['customer']).to include('name' => 'Nowak', 'given_names' => 'Jan Maria', 'birth_date' => '1969-07-06')
    expect(json['meta']).to eq('collection' => { 'offset' => 0, 'limit' => 1, 'objects' => 1 })
    expect(ConfirmationLog.last.remote_ip).to eq '203.0.113.5'
    expect(ConfirmationLog.last.request_json).to include certificate.verification_code
  end

  it 'świadectwo bezterminowe: pusta valid_thru' do
    perpetual = create_certificate(division: goc, number: 'GG-07777', valid_thru: nil)
    search_by_code(perpetual.verification_code)
    expect(json['certificates'].first['valid_thru']).to eq ''
  end

  it 'brak kodu: 406, bez logu' do
    expect { search_by_code('') }.not_to change(ConfirmationLog, :count)
    expect(response).to have_http_status(:not_acceptable)
  end

  {
    'nieznany kod' => '7KD3M9QX2PNAHT5V',
    'zły format' => 'abc',
    'próba wstrzyknięcia SQL' => "x' OR '1'='1"
  }.each do |name, code|
    it "brak danych: #{name} (404, log)" do
      expect { search_by_code(code) }.to change(ConfirmationLog, :count).by(1)
      expect(response).to have_http_status(:not_found)
      expect(json).to eq('error' => 'Brak danych / No data')
    end
  end

  it 'świadectwo anulowane: 404' do
    certificate.update_columns(canceled: true)
    search_by_code(certificate.verification_code)
    expect(response).to have_http_status(:not_found)
  end

  it 'rodzaj wyłączony z weryfikacji internetowej: 403' do
    other = create_certificate(division: cso, number: 'GC-00001')
    search_by_code(other.verification_code)
    expect(response).to have_http_status(:forbidden)
    expect(json['error']).to include 'Rodzaj świadectwa nie podlega weryfikacji internetowej'
  end

  it 'stary adres (api/v1/confirmation/codes/:code) – usunięty' do
    expect { get "/api/v1/confirmation/codes/#{certificate.verification_code}", {}, api_headers }.to raise_error(ActionController::RoutingError)
  end
end
