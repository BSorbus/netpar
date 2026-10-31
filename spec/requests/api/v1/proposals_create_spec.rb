require 'rails_helper'

# Tworzenie zgłoszeń przez aplikację Egzaminy – bez duplikatów przy ponownym wysłaniu.
RSpec.describe 'API v1 POST /proposals', type: :request do
  let!(:statuses) { (1..10).map { |id| ProposalStatus.new(name: "Status #{id}").tap { |s| s.id = id; s.save!(validate: false) } } }
  let!(:division) { create_division(category: 'R', short_name: 'A', name: 'świadectwo klasy A', number_prefix: 'A-') }
  let!(:exam) { FactoryBot.build(:exam, category: 'R', esod_category: 47, max_examinations: 10, date_exam: Date.today + 30).tap { |e| e.save!(validate: false) } }
  let!(:exam_fee) { ExamFee.new(division_id: division.id, esod_category: 41, price: 75).tap { |f| f.save!(validate: false) } }
  let(:uuid) { SecureRandom.uuid }
  let(:data) do
    { 'multi_app_identifier' => uuid, 'proposal_status_id' => 1, 'category' => 'R', 'esod_category' => 41,
      'name' => 'Testowy', 'given_names' => 'Jan', 'email' => 'jan@example.com',
      'division_id' => division.id, 'exam_id' => exam.id, 'exam_fee_id' => exam_fee.id, 'exam_fee_price' => '75.0' }
  end

  def post_proposal(payload)
    post '/api/v1/proposals', { proposal: payload }, api_headers
  end

  # Odpowiedź NETPAR: {"proposal": {...}}
  def response_id
    (json['proposal'] || json)['id']
  end

  it 'tworzy zgłoszenie (JSON z Egzaminów 8)' do
    post_proposal(data.to_json)

    expect(response).to have_http_status(:created)
    expect(Proposal.where(multi_app_identifier: uuid).count).to eq 1
  end

  it "zapisuje wymóg zdjęcia przekazany przez Egzaminy (division_face_image_required)" do
    post_proposal(data.merge("division_face_image_required" => true).to_json)

    expect(response).to have_http_status(:created)
    expect(Proposal.find_by(multi_app_identifier: uuid).division_face_image_required).to eq true
  end

  it 'przyjmuje stary format (Hash#to_s z Egzaminów)' do
    post_proposal(data.to_s)

    expect(response).to have_http_status(:created)
  end

  it 'ponowne wysłanie tego samego zgłoszenia zwraca istniejące – bez duplikatu' do
    post_proposal(data.to_json)
    first_id = response_id

    post_proposal(data.merge('name' => 'Inne').to_json)

    expect(response).to have_http_status(:ok)
    expect(response_id).to eq first_id
    expect(Proposal.where(multi_app_identifier: uuid).count).to eq 1
    expect(Proposal.find(first_id).name).to eq 'Testowy'
  end

  it 'równoczesne wysłanie: unikalny indeks zatrzymuje drugi zapis, odpowiedź – istniejące zgłoszenie' do
    post_proposal(data.to_json)
    first_id = response_id
    # Drugie żądanie „nie widzi” jeszcze pierwszego zapisu (jak przy dwóch żądaniach w tej samej chwili).
    allow_any_instance_of(Api::V1::ProposalsController).to receive(:existing_proposal).and_return(nil, Proposal.find(first_id))

    post_proposal(data.to_json)

    expect(response).to have_http_status(:ok)
    expect(response_id).to eq first_id
    expect(Proposal.where(multi_app_identifier: uuid).count).to eq 1
  end

  it 'unikalny indeks w bazie dla nowych zgłoszeń' do
    post_proposal(data.to_json)
    duplicate = Proposal.find(response_id).dup

    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'nowe zgłoszenie zawsze „utworzone”, test zablokowany – niezależnie od przysłanych danych' do
    post_proposal(data.merge('proposal_status_id' => 2, 'test_unlocked' => true).to_json)

    proposal = Proposal.find_by(multi_app_identifier: uuid)
    expect([proposal.proposal_status_id, proposal.test_unlocked]).to eq [1, false]
  end

  it 'JSON najpierw: „=>” w tekście nie jest zamieniane' do
    post_proposal(data.merge('birth_place' => 'Gdynia => Gdańsk').to_json)

    expect(Proposal.find_by(multi_app_identifier: uuid).birth_place).to eq 'Gdynia => Gdańsk'
  end

  it 'niepoprawne dane: 422' do
    post_proposal('nie json')

    expect(response).to have_http_status(:unprocessable_entity)
  end

  describe 'PATCH /proposals/:multi_app_identifier' do
    before { post_proposal(data.to_json) }

    def patch_proposal(changes)
      patch "/api/v1/proposals/#{uuid}", { proposal: changes.to_s }, api_headers
    end

    it 'anulowanie zgłoszenia „utworzone” (format dotychczasowej aplikacji)' do
      patch_proposal(data.merge('proposal_status_id' => 5))

      expect(response).to have_http_status(:ok)
      expect(Proposal.find_by(multi_app_identifier: uuid).proposal_status_id).to eq 5
    end

    it 'inna zmiana statusu przez API – 422, bez zmian' do
      patch_proposal(data.merge('proposal_status_id' => 2))

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Proposal.find_by(multi_app_identifier: uuid).proposal_status_id).to eq 1
    end

    it 'anulowanie zgłoszenia odrzuconego – 422' do
      Proposal.find_by(multi_app_identifier: uuid).update_columns(proposal_status_id: 3)
      patch_proposal(data.merge('proposal_status_id' => 5))

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'ten sam status i odblokowanie testu: status bez zmian, test nadal zablokowany' do
      patch_proposal(data.merge('proposal_status_id' => 1, 'test_unlocked' => true, 'phone' => '123'))

      proposal = Proposal.find_by(multi_app_identifier: uuid)
      expect(response).to have_http_status(:ok)
      expect([proposal.proposal_status_id, proposal.test_unlocked, proposal.phone]).to eq [1, false, '123']
    end
  end
end
