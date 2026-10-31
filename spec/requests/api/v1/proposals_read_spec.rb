require 'rails_helper'

# Odczyt zgłoszeń przez aplikację Egzaminy: lista zgłoszeń użytkownika i jedno zgłoszenie (komplet pól).
RSpec.describe 'API v1 GET /proposals', type: :request do
  let!(:statuses) { (1..10).map { |id| ProposalStatus.new(name: "Status #{id}").tap { |s| s.id = id; s.save!(validate: false) } } }
  let!(:division) { create_division(category: 'R', short_name: 'A', name: 'świadectwo klasy A', number_prefix: 'A-') }
  let!(:exam) { FactoryBot.build(:exam, category: 'R', esod_category: 47, max_examinations: 10, date_exam: Date.today + 30).tap { |e| e.save!(validate: false) } }

  def create_proposal(attributes)
    Proposal.new({ multi_app_identifier: SecureRandom.uuid, proposal_status_id: 1, category: 'R', esod_category: 41,
                   name: 'Testowy', given_names: 'Jan', email: 'jan@example.com', division_id: division.id, exam_id: exam.id }.merge(attributes))
            .tap { |proposal| proposal.save!(validate: false) }
  end

  describe 'lista' do
    it 'zwraca zgłoszenia jednego użytkownika (creator_id) – komplet pól, wg id' do
      first = create_proposal(creator_id: 17, division_short_name: 'A')
      second = create_proposal(creator_id: 17, proposal_status_id: 5)
      create_proposal(creator_id: 18)

      get '/api/v1/proposals', { creator_id: 17 }, api_headers

      expect(response).to have_http_status(:ok)
      expect(json['proposals'].map { |p| p['id'] }).to eq [first.id, second.id]
      expect(json['meta']).to eq('total_count' => 2)
      expect(json['proposals'].first).to include('multi_app_identifier' => first.multi_app_identifier, 'division_id' => division.id,
                                                  'division_short_name' => 'A', 'proposal_status_id' => 1, 'creator_id' => 17)
      expect(json['proposals'].first.keys).to include('exam_id', 'exam_date_exam', 'division_face_image_required', 'fullname')
    end

    it "zawiera status (id i nazwa) oraz egzamin z ocenami (po akceptacji); bez egzaminu – null" do
      accepted = create_proposal(creator_id: 17, proposal_status_id: 2)
      waiting = create_proposal(creator_id: 17)
      subject_1 = Subject.new(division: division, item: 1, name: "Przepisy", esod_categories: %w(41)).tap { |s| s.save!(validate: false) }
      subject_2 = Subject.new(division: division, item: 2, name: "Technika", esod_categories: %w(41)).tap { |s| s.save!(validate: false) }
      examination = Examination.new(proposal_id: accepted.id, division_id: division.id, exam_id: exam.id, category: "R", esod_category: 41,
                                    examination_result: "P").tap { |e| e.save!(validate: false) }
      Grade.new(examination_id: examination.id, subject_id: subject_2.id, grade_result: "N").save!(validate: false)
      Grade.new(examination_id: examination.id, subject_id: subject_1.id, grade_result: "P").save!(validate: false)

      get "/api/v1/proposals", { creator_id: 17 }, api_headers

      rows = json["proposals"].index_by { |p| p["id"] }
      expect(rows[accepted.id]["proposal_status"]).to eq("id" => 2, "name" => "Status 2")
      expect(rows[accepted.id]["examination"]).to include("id" => examination.id, "examination_result" => "P")
      expect(rows[accepted.id]["examination"]["grades"].map { |g| g.values_at("subject_item", "subject_name", "grade_result") })
        .to eq [[2, "Technika", "N"], [1, "Przepisy", "P"]]
      expect(rows[waiting.id]["examination"]).to be_nil
    end

    it 'bez creator_id: 422 (bez zgłoszeń wszystkich użytkowników)' do
      create_proposal(creator_id: 17)

      get '/api/v1/proposals', {}, api_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to eq('error' => 'Brak parametru creator_id')
    end
  end

  describe 'jedno zgłoszenie' do
    it 'po multi_app_identifier – komplet pól' do
      proposal = create_proposal(creator_id: 17)

      get "/api/v1/proposals/#{proposal.multi_app_identifier}", {}, api_headers

      expect(response).to have_http_status(:ok)
      expect(json).to include('id' => proposal.id, 'multi_app_identifier' => proposal.multi_app_identifier, 'division_id' => division.id)
    end

    it 'nieistniejące: 404' do
      get "/api/v1/proposals/#{SecureRandom.uuid}", {}, api_headers

      expect(response).to have_http_status(:not_found)
      expect(json).to have_key('error')
    end
  end
end
