require 'rails_helper'

# Błędne parametry i logowanie do API – odpowiedzi 422 / 401 zamiast błędu 500.
RSpec.describe 'API v1 – parametry i token', type: :request do
  it '/exams bez kategorii albo z nieznaną kategorią – 422' do
    get '/api/v1/exams', { division_id: 1 }, api_headers
    expect(response).to have_http_status(:unprocessable_entity)

    get '/api/v1/exams', { category: 'X', division_id: 1 }, api_headers
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json['error']).to include('Nieprawidłowa kategoria')
  end

  it '/exam_fees/find z błędną datą – 422' do
    get '/api/v1/exam_fees/find', { division_id: 1, esod_category: 41, for_date: "2026-13-45' OR 1=1" }, api_headers

    expect(response).to have_http_status(:unprocessable_entity)
  end

  describe '/token' do
    let!(:key) { ApiKey.create!(name: 'egzaminy') }

    it 'bez danych logowania – 401' do
      get '/api/v1/token'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'złe hasło – 401, dobre – token' do
      get '/api/v1/token', {}, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('egzaminy', 'złe')
      expect(response).to have_http_status(:unauthorized)

      get '/api/v1/token', {}, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('egzaminy', key.password)
      expect(json['token']).to eq key.access_token
    end
  end
end
