require 'rails_helper'

# Lista typów świadectw (DataTables): dane z wzorem karty obowiązującym dziś; tylko z prawem division:index.
RSpec.describe DivisionsController, type: :controller do
  include ApiHelpers # create_division

  let(:user) { FactoryBot.create(:user) }
  let!(:goc) { create_division(category: 'M', short_name: 'GOC', name: 'świadectwo ogólne operatora GMDSS', number_prefix: 'GG-',
                               enabled_in_confirmation: true, face_image_required: true) }
  let!(:src) { create_division(category: 'M', short_name: 'SRC', name: 'świadectwo operatora łączności bliskiego zasięgu', number_prefix: 'GS-',
                               for_new_certificate: false, proposal_via_internet: false) }

  def file(name, type = 'image/png')
    Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', name), type)
  end

  before { sign_in user }

  it 'dane listy: przełączniki typu i wzór karty obowiązujący dziś (bez wzoru – blankiet)' do
    allow_any_instance_of(DivisionPolicy).to receive(:index?).and_return(true)
    CertificateCardTemplate.create!(division: goc, name: 'Stary', valid_from: Date.today - 400, valid_to: Date.today - 31,
                                    card_front: file('card_ok.png'), card_back: file('card_ok.png'))
    current = CertificateCardTemplate.create!(division: goc, name: 'Karta GOC', valid_from: Date.today - 30,
                                              card_front: file('card_ok.png'), card_back: file('card_ok.png'))

    post :datatables_index, format: :json
    rows = JSON.parse(response.body)['data'].index_by { |row| row['short_name'] }

    expect(rows['GOC']).to include('number_prefix' => 'GG-', 'face_image_required' => true, 'for_new_certificate' => true,
                                   'enabled_in_confirmation' => true, 'card_template_id' => current.id, 'card_template_name' => 'Karta GOC')
    expect(rows['GOC']['category_fullname']).to start_with '[M]'
    expect(rows['SRC']).to include('for_new_certificate' => false, 'proposal_via_internet' => false, 'card_template_id' => nil)
  end

  it 'bez prawa division:index – 403, bez danych' do
    allow_any_instance_of(DivisionPolicy).to receive(:index?).and_return(false)
    post :datatables_index, format: :json
    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)).not_to have_key('data')
  end
end
