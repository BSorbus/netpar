require 'rails_helper'

# Odczyt szczegółów zgłoszenia z aplikacji Egzaminy (panel w szczegółach wniosku).
RSpec.describe EgzaminyProposal, type: :model do
  describe '.details_enabled?' do
    before { allow(Rails.application.secrets).to receive(:[]).and_call_original }

    it 'sekcja „Aplikacja Egzaminy” tylko przy egzaminy_details: true w secrets.yml (stara aplikacja Egzaminy nie ma API szczegółów)' do
      { nil => false, false => false, true => true, 'true' => true }.each do |value, enabled|
        allow(Rails.application.secrets).to receive(:[]).with(:egzaminy_details).and_return(value)
        expect(EgzaminyProposal.details_enabled?).to eq enabled
      end
    end
  end

  describe '.find_details' do
    before do
      allow(EgzaminyUser).to receive(:egzaminyuser_token).and_return('tok-1')
      allow(Rails.application.secrets).to receive(:[]).and_call_original
      allow(Rails.application.secrets).to receive(:[]).with(:egzaminy_api_url).and_return('https://egzaminy.test')
    end

    def http_response(klass, code, body)
      klass.new('1.1', code, '').tap { |response| allow(response).to receive(:body).and_return(body) }
    end

    def stub_http(response)
      http = double('http')
      allow(http).to receive(:request) do |request|
        expect(request['Authorization']).to eq 'Token token=tok-1'
        expect(request.path).to eq '/api/v1/proposals/abc-123'
        response
      end
      allow(Net::HTTP).to receive(:start) { |*_args, &block| block.call(http) }
    end

    it 'zwraca dane zgłoszenia ze zgodami RODO i historią (z tokenem)' do
      stub_http(http_response(Net::HTTPOK, '200', { 'multi_app_identifier' => 'abc-123', 'events' => [] }.to_json))
      expect(described_class.find_details('abc-123')).to eq [true, { 'multi_app_identifier' => 'abc-123', 'events' => [] }]
    end

    it 'brak zgłoszenia w Egzaminach – czytelny komunikat' do
      stub_http(http_response(Net::HTTPNotFound, '404', '{"error":"Brak"}'))
      expect(described_class.find_details('abc-123')).to eq [false, 'W aplikacji Egzaminy nie ma tego zgłoszenia']
    end

    it 'błąd serwera Egzaminów albo brak połączenia – opis błędu, bez wyjątku' do
      stub_http(http_response(Net::HTTPInternalServerError, '500', 'błąd'))
      expect(described_class.find_details('abc-123')).to eq [false, 'HTTP 500']

      allow(Net::HTTP).to receive(:start).and_raise(Net::OpenTimeout, 'execution expired')
      expect(described_class.find_details('abc-123')).to eq [false, 'execution expired']
    end
  end
end
