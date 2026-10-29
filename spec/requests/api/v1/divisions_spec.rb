require 'rails_helper'

RSpec.describe 'API v1 divisions', type: :request do
  let!(:goc) { create_division(id: 11, category: 'M', short_name: 'GOC', name: 'świadectwo ogólne operatora GMDSS', number_prefix: 'GG-', min_years_old: 18, face_image_required: true, proposal_via_internet: false, enabled_in_confirmation: true) }
  let!(:src) { create_division(id: 14, category: 'M', short_name: 'SRC', name: 'świadectwo operatora łączności bliskiego zasięgu SRC', number_prefix: 'GS-', proposal_via_internet: true, enabled_in_confirmation: true) }
  let!(:cso) { create_division(id: 16, category: 'M', short_name: 'CSO', name: 'świadectwo operatora stacji nadbrzeżnej CSO', number_prefix: 'GC-', proposal_via_internet: false, enabled_in_confirmation: false) }
  let!(:or_l) { create_division(id: 1, category: 'L', short_name: 'OR', name: 'świadectwo ogólne operatora radiotelefonisty', number_prefix: 'L-', proposal_via_internet: true, enabled_in_confirmation: false) }
  let!(:ra_a) { create_division(id: 18, category: 'R', short_name: 'A', name: 'świadectwo klasy A', number_prefix: 'A-', proposal_via_internet: true, enabled_in_confirmation: true) }

  def ids
    json['divisions'].map { |division| division['id'] }
  end

  it 'wymaga tokenu' do
    get '/api/v1/divisions', enabled_in_confirmation: 'true'
    expect(response).to have_http_status(:unauthorized)
  end

  describe 'enabled_in_confirmation=true' do
    it 'zwraca rodzaje włączone do weryfikacji ze wszystkich kategorii, wg id, bez stronicowania' do
      get '/api/v1/divisions', { enabled_in_confirmation: 'true' }, api_headers

      expect(response).to have_http_status(:ok)
      expect(ids).to eq [11, 14, 18]
      expect(json['meta']).to eq('total_count' => 3)
    end

    it 'zwraca pełny opis rodzaju' do
      get '/api/v1/divisions', { enabled_in_confirmation: 'true', category: 'M' }, api_headers

      expect(json['divisions'].first).to eq(
        'id' => 11, 'name' => 'świadectwo ogólne operatora GMDSS', 'english_name' => 'EN GOC', 'short_name' => 'GOC',
        'number_prefix' => 'GG-', 'category' => 'M', 'min_years_old' => 18, 'face_image_required' => true,
        'for_new_certificate' => true, 'proposal_via_internet' => false, 'enabled_in_confirmation' => true,
        'fullname' => 'świadectwo ogólne operatora GMDSS, [GOC][ukończone 18 lat]'
      )
    end

    it 'filtruje po kategorii (wielkość liter bez znaczenia)' do
      get '/api/v1/divisions', { enabled_in_confirmation: 'true', category: 'm' }, api_headers
      expect(ids).to eq [11, 14]
    end

    it 'wyszukuje po q' do
      get '/api/v1/divisions', { enabled_in_confirmation: 'true', q: 'gmdss' }, api_headers
      expect(ids).to eq [11]
    end

    it 'stronicuje tylko z page_limit; total_count to liczba wszystkich' do
      get '/api/v1/divisions', { enabled_in_confirmation: 'true', page_limit: 2, page: 2 }, api_headers

      expect(ids).to eq [18]
      expect(json['meta']).to eq('total_count' => 3)
    end

    it 'q z próbą wstrzyknięcia SQL nie zmienia zapytania' do
      get '/api/v1/divisions', { enabled_in_confirmation: 'true', q: "x' OR '1'='1" }, api_headers

      expect(response).to have_http_status(:ok)
      expect(ids).to be_empty
    end

    it 'odrzuca nieznaną kategorię' do
      expect {
        get '/api/v1/divisions', { enabled_in_confirmation: 'true', category: "M' OR '1'='1" }, api_headers
      }.to raise_error(RuntimeError, 'Ruby injection')
    end
  end

  describe 'enabled_in_examination=true' do
    it 'zwraca rodzaje dla zapisów przez internet (proposal_via_internet) ze wszystkich kategorii, wg id' do
      get '/api/v1/divisions', { enabled_in_examination: 'true' }, api_headers

      expect(ids).to eq [1, 14, 18]
      expect(json['meta']).to eq('total_count' => 3)
    end

    it 'filtruje po kategorii i q' do
      get '/api/v1/divisions', { enabled_in_examination: 'true', category: 'M', q: 'src' }, api_headers
      expect(ids).to eq [14]
    end
  end

  describe 'bez parametrów enabled_in_*' do
    it 'działa jak dotychczas: proposal_via_internet, wymagana kategoria, wg nazwy' do
      get '/api/v1/divisions', { category: 'M' }, api_headers
      expect(ids).to eq [14]

      get '/api/v1/divisions', {}, api_headers
      expect(ids).to be_empty
    end
  end

  describe 'GET /api/v1/divisions/:id' do
    it 'zwraca każdy rodzaj, także niewłączony' do
      get '/api/v1/divisions/16', {}, api_headers

      expect(response).to have_http_status(:ok)
      expect(json).to include('id' => 16, 'short_name' => 'CSO', 'proposal_via_internet' => false, 'enabled_in_confirmation' => false)
    end

    it 'nieistniejący rodzaj: 404' do
      get '/api/v1/divisions/999', {}, api_headers

      expect(response).to have_http_status(:not_found)
      expect(json).to have_key('error')
    end
  end
end
