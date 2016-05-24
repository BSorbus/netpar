Rails.application.routes.draw do

  devise_for :users, controllers: {
    passwords: 'users/passwords',
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    unlocks: 'users/unlocks'
  }

  resources :users do
    resources :documents, module: :users, only: [:create]
    post 'datatables_index', on: :collection
    patch 'account_off', on: :member
    patch 'account_on', on: :member
    get 'user_permissions_to_pdf', on: :member
    get 'user_activity_to_pdf', on: :member
  end


  scope ':category_service', constraints: { category_service: /[lmr]/ } do
    resources :certificates do
      post 'datatables_index', on: :collection
      post 'datatables_index_exam', on: :collection # for Exam
      get 'select2_index', on: :collection
      get 'search', on: :collection
      get 'certificate_to_pdf', on: :member
      post 'esod_matter_link', on: :member
    end
    resources :exams do
      post 'datatables_index', on: :collection
      get 'select2_index', on: :collection
      get 'examination_cards_to_pdf', on: :member
      get 'examination_protocol_to_pdf', on: :member
      get 'exam_report_to_pdf', on: :member
      get 'certificates_to_pdf', on: :member
      get 'envelopes_to_pdf', on: :member
      get 'committee_docx', on: :member
      patch 'certificates_generation', on: :member
      post 'esod_matter_link', on: :member
    end
    resources :examinations do
      post 'datatables_index_exam', on: :collection # for Exam
      get 'examination_card_to_pdf', on: :member
      patch 'certificate_generation', on: :member
      post 'esod_matter_link', on: :member
    end
  end

  resources :exams, only: [] do
    resources :documents, module: :exams, only: [:create]
    resources :esod_matters, module: :exams, only: [:create]
    resources :esod_incoming_letters, module: :exams, only: [:create]
    resources :esod_outgoing_letters, module: :exams, only: [:create]
    resources :esod_internal_letters, module: :exams, only: [:create]
  end

  resources :examinations, only: [] do
    resources :documents, module: :examinations, only: [:create]
    resources :esod_matters, module: :examinations, only: [:create]
    resources :esod_incoming_letters, module: :examinations, only: [:create]
    resources :esod_outgoing_letters, module: :examinations, only: [:create]
    resources :esod_internal_letters, module: :examinations, only: [:create]
  end

  resources :certificates, only: [] do
    resources :documents, module: :certificates, only: [:create]
    resources :esod_matters, module: :certificates, only: [:create]
    resources :esod_incoming_letters, module: :certificates, only: [:create]
    resources :esod_outgoing_letters, module: :certificates, only: [:create]
    resources :esod_internal_letters, module: :certificates, only: [:create]
  end


  resources :customers do
    post 'datatables_index', on: :collection
    get 'select2_index', on: :collection
    post 'merge', on: :member
    get 'envelope_to_pdf', on: :member
    get 'history_to_pdf', on: :member
    resources :documents, module: :customers, only: [:create]
  end

  resources :departments

  resources :roles do
  	resources :users, only: [:create, :destroy], controller: 'roles/users'
  end

  resources :documents, only: [:show, :destroy]

  resources :works, only: [:index] do
    post 'datatables_index', on: :collection # for User
    post 'datatables_index_trackable', on: :collection # for Trackable
    post 'datatables_index_user', on: :collection # for User
  end


  namespace :teryt do
    resources :pna_codes, only: [:show] do
      get 'select2_index', on: :collection
    end
  end

  namespace :esod do
    resources :contractors
    resources :matters do
      post 'datatables_index', on: :collection
      get 'select2_index', on: :collection
      resources :incoming_letters, only: [:show, :create], controller: 'matters/incoming_letters'
      resources :outgoing_letters
      resources :internal_letters
    end
  end




  root to: 'visitors#index'

  mount SwaggerEngine::Engine, at: "/api-docs"
  #mount Refile.app, at: "files", as: :refile_app

  namespace :api, defaults: { format: :json } do
    require 'api_constraints'
    #scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
    namespace :v1, constraints: ApiConstraints.new(version: 1, default: true) do
    #namespace :v1 do
      mount Refile.app, at: "attachments", as: :refile_app
      resources :certificates, only: [:show] do
        get 'lot', on: :collection
        get 'mor', on: :collection
        get 'ra', on: :collection
        get 'lot_search_by_number', on: :collection
        get 'mor_search_by_number', on: :collection
        get 'ra_search_by_number', on: :collection
        get 'all_search_by_number', on: :collection
        get 'lot_search_by_customer_pesel', on: :collection
        get 'mor_search_by_customer_pesel', on: :collection
        get 'ra_search_by_customer_pesel', on: :collection
        get 'all_search_by_customer_pesel', on: :collection
      end
      devise_scope :user do
        post 'sessions' => 'sessions#create' #, :as => 'login'
        delete 'sessions' => 'sessions#destroy' #, :as => 'logout'

        post 'login' => 'sessions#create' #, :as => 'login'
        delete 'logout' => 'sessions#destroy' #, :as => 'logout'
      end

    end

    #namespace :v2, constraints: ApiConstraints.new(version: 1, default: false) do
    namespace :v2 do
    end

    #match "*path", to: -> (env) { [404, {}, ['{"error": "Oops! Nie znalazłem takiej ścieżki"}']] }, via: :all
  end

  #match "*path", to: -> (env) { [404, {}, ['{"error": "Oops! Nie znalazłem takiej ścieżki. Prawiodłowe wywołanie API: https://netpar2015.uke.gov.pl/api/v1/..."}']] }, via: :all
end
