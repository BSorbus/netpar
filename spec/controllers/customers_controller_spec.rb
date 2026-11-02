require 'rails_helper'

# Poprawa danych osoby ze strony wniosku: po zapisie powrót do wniosku (back_url – tylko adres w aplikacji).
RSpec.describe CustomersController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:customer) { FactoryBot.create(:customer, human: true, name: 'JARZAB', given_names: 'BOGDAN', birth_date: Date.new(1969, 7, 6),
                                                    birth_place: 'Więcbork', citizenship_code: 'PL', user: user) }

  before do
    sign_in user
    allow_any_instance_of(CustomerPolicy).to receive(:update?).and_return(true)
  end

  it 'zapis z back_url wniosku – powrót do wniosku, poprawione imiona i nazwisko' do
    patch :update, id: customer.id, back_url: '/m/proposals/537', customer: { name: 'Jarząb', given_names: 'Bogdan' }
    expect(response).to redirect_to '/m/proposals/537'
    expect(customer.reload.certificate_name).to eq 'Bogdan JARZĄB'
  end

  it 'back_url spoza aplikacji – ignorowany (powrót do osoby)' do
    patch :update, id: customer.id, back_url: '//evil.example/x', customer: { given_names: 'Bogdan' }
    expect(response).to redirect_to customer_path(customer)
    patch :update, id: customer.id, back_url: 'https://evil.example/x', customer: { given_names: 'Bogdan' }
    expect(response).to redirect_to customer_path(customer)
  end
end
