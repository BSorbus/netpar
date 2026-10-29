require 'rails_helper'

RSpec.describe 'API v1 confirmation/certificates/search', type: :request do
  let!(:goc) { create_division(category: 'M', short_name: 'GOC', name: 'świadectwo ogólne operatora GMDSS', number_prefix: 'GG-', enabled_in_confirmation: true) }
  let!(:cso) { create_division(category: 'M', short_name: 'CSO', name: 'świadectwo operatora stacji nadbrzeżnej CSO', number_prefix: 'GC-', enabled_in_confirmation: false) }
  let!(:or_l) { create_division(category: 'L', short_name: 'OR', name: 'świadectwo ogólne operatora radiotelefonisty', number_prefix: 'L-', enabled_in_confirmation: true) }
  let!(:certificate) { create_certificate(division: goc, number: 'GG-05998') }

  let(:params) do
    { category: 'M', number_prefix: 'GG-', number: '05998', date_of_issue: '2018-08-30', valid_thru: '2028-08-30',
      name: 'kozlowski', given_names: 'JAN MARIA', birth_date: '1969-07-06' }
  end

  def search(overrides = {})
    get '/api/v1/confirmation/certificates/search', params.merge(overrides), api_headers('HTTP_X_REAL_IP' => '203.0.113.5')
  end

  it 'wymaga tokenu' do
    get '/api/v1/confirmation/certificates/search', params
    expect(response).to have_http_status(:unauthorized)
  end

  it 'potwierdza świadectwo (nazwisko bez polskich znaków i wielkości liter) i zapisuje log' do
    expect { search }.to change(ConfirmationLog, :count).by(1)

    expect(response).to have_http_status(:ok)
    found = json['certificates'].first
    expect(found).to include('id' => certificate.id, 'number' => 'GG-05998', 'date_of_issue' => '2018-08-30',
                             'valid_thru' => '2028-08-30', 'category' => 'M')
    expect(found['division']).to eq('id' => goc.id, 'name' => 'świadectwo ogólne operatora GMDSS', 'english_name' => 'EN GOC',
                                    'short_name' => 'GOC', 'number_prefix' => 'GG-')
    expect(found['customer']).to include('name' => 'Kozłowski', 'given_names' => 'Jan Maria', 'birth_date' => '1969-07-06')
    expect(ConfirmationLog.last.remote_ip).to eq '203.0.113.5'
  end

  it 'świadectwo bezterminowe: pusta valid_thru' do
    create_certificate(division: goc, number: 'GG-07777', valid_thru: nil)

    search(number: '07777', valid_thru: '')
    expect(response).to have_http_status(:ok)
  end

  it 'pusta valid_thru nie potwierdza świadectwa terminowego' do
    search(valid_thru: '')
    expect(response).to have_http_status(:not_found)
  end

  it 'potwierdza dane sprzed zmiany (historia zmian świadectwa)' do
    certificate.customer.update_columns(name: 'Nowak')
    Work.create!(trackable: certificate, action: 'update', parameters: {
      id: certificate.id, number: 'GG-05998', date_of_issue: '2018-08-30', valid_thru: '2028-08-30',
      customer: { id: certificate.customer.id, name: 'Kozłowski', given_names: 'Jan Maria', birth_date: '1969-07-06' }
    }.to_json)

    search
    expect(response).to have_http_status(:ok)
    expect(json['certificates'].first['customer']['name']).to eq 'Kozłowski'
  end

  it 'kategorie L i R przez ten sam endpoint' do
    create_certificate(division: or_l, number: 'L-1234')

    search(category: 'L', number_prefix: 'L-', number: '1234')
    expect(response).to have_http_status(:ok)
    expect(json['certificates'].first['category']).to eq 'L'
  end

  {
    'niezgodne nazwisko' => { name: 'kowalski' },
    'niezgodna data urodzenia' => { birth_date: '1969-07-07' },
    'niezgodna data wydania' => { date_of_issue: '2018-08-31' },
    'świadectwo z innej kategorii' => { category: 'L' },
    'nieistniejący numer' => { number: '99999' }
  }.each do |name, overrides|
    it "brak danych: #{name} (404, log)" do
      expect { search(overrides) }.to change(ConfirmationLog, :count).by(1)

      expect(response).to have_http_status(:not_found)
      expect(json).to eq('error' => 'Brak danych / No data')
    end
  end

  it 'rodzaj niewłączony do weryfikacji: 404 jak brak danych' do
    create_certificate(division: cso, number: 'GC-00001')

    search(number_prefix: 'GC-', number: '00001')
    expect(response).to have_http_status(:not_found)
  end

  it 'świadectwo anulowane: 404' do
    certificate.update_columns(canceled: true)

    search
    expect(response).to have_http_status(:not_found)
  end

  it 'próba wstrzyknięcia SQL w numerze: 404' do
    search(number: "x' OR '1'='1")

    expect(response).to have_http_status(:not_found)
  end

  [:category, :number_prefix, :number, :date_of_issue, :name, :given_names, :birth_date].each do |field|
    it "brak parametru #{field}: 406" do
      expect { search(field => '') }.not_to change(ConfirmationLog, :count)

      expect(response).to have_http_status(:not_acceptable)
    end
  end

  it 'nieznana kategoria: 406' do
    search(category: 'X')
    expect(response).to have_http_status(:not_acceptable)
  end
end
