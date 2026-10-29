# Pomocnicze metody do testów API v1 (uwierzytelnienie tokenem, odczyt JSON, dane świadectw).
module ApiHelpers
  def api_key
    @api_key ||= ApiKey.create!(name: 'confirmation')
  end

  def api_headers(extra = {})
    { 'HTTP_AUTHORIZATION' => "Token token=#{api_key.access_token}" }.merge(extra)
  end

  def json
    JSON.parse(response.body)
  end

  def create_division(attributes)
    FactoryBot.create(:division, { english_name: "EN #{attributes[:short_name]}" }.merge(attributes))
  end

  # Świadectwo z klientem – zapis bez walidacji (egzamin, użytkownik i PESEL nie mają znaczenia dla API weryfikacji).
  def create_certificate(division:, number:, customer: {}, **attributes)
    person = FactoryBot.build(:customer, { human: true, name: 'Kozłowski', given_names: 'Jan Maria', birth_date: '1969-07-06' }.merge(customer))
    person.save!(validate: false)
    certificate = FactoryBot.build(:certificate, { category: division.category, date_of_issue: '2018-08-30', valid_thru: '2028-08-30' }
                                                   .merge(attributes).merge(division: division, customer: person, number: number))
    certificate.save!(validate: false)
    certificate
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
