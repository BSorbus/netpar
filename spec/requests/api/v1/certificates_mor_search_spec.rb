require 'rails_helper'

# Endpoint używany przez dotychczasową aplikację Confirmation – zostaje do czasu przełączenia na confirmation/certificates/search.
RSpec.describe 'API v1 certificates/mor_search_by_multi_params', type: :request do
  let!(:goc) { create_division(category: 'M', short_name: 'GOC', name: 'świadectwo ogólne operatora GMDSS', number_prefix: 'GG-') }
  let!(:certificate) { create_certificate(division: goc, number: 'GG-05998') }

  let(:params) do
    { number_prefix: 'GG-', number: '05998', date_of_issue: '2018-08-30', valid_thru: '2028-08-30',
      name: 'kozlowski', given_names: 'JAN MARIA', birth_date: '1969-07-06' }
  end

  it 'potwierdza świadectwo morskie' do
    get '/api/v1/certificates/mor_search_by_multi_params', params, api_headers

    expect(response).to have_http_status(:ok)
    expect(json['certificates'].first['number']).to eq 'GG-05998'
  end

  it 'próba wstrzyknięcia SQL w numerze: 404, bez błędu bazy' do
    get '/api/v1/certificates/mor_search_by_multi_params', params.merge(number: "x' OR '1'='1"), api_headers

    expect(response).to have_http_status(:not_found)
  end
end
