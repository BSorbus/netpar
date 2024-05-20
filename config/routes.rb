Rails.application.routes.draw do

  resources :licenses, only: [:index, :show] do
    post 'datatables_index', on: :collection
  end

  # devise_for :users, controllers: {
  #   passwords: 'users/passwords',
  #   sessions: 'users/sessions',
  #   registrations: 'users/registrations',
  #   unlocks: 'users/unlocks'
  # }

  devise_for :users, controllers: {
    saml_sessions: 'users/saml_sessions'
  }

  resources :users do
    resources :documents, module: :users, only: [:create]
    post 'datatables_index', on: :collection
    patch 'account_off', on: :member
    patch 'account_on', on: :member
    get 'user_permissions_to_pdf', on: :member
    get 'user_activity_to_pdf', on: :member
    post 'datatables_index_role', on: :collection # for User
  end


  scope ':category_service', constraints: { category_service: /[lmr]/ } do
    resources :proposals, except: [:create, :destroy] do
      #get 'show_charts', on: :collection
      get 'edit_approved', on: :member
      patch 'update_approved', on: :member
      get 'edit_not_approved', on: :member
      patch 'update_not_approved', on: :member
      get 'edit_closed', on: :member
      patch 'update_closed', on: :member
      post 'datatables_index', on: :collection
      post 'datatables_index_exam', on: :collection # for Exam
    end
    resources :certificates do
      get 'show_charts', on: :collection
      post 'datatables_index', on: :collection
      post 'datatables_index_exam', on: :collection # for Exam
      get 'select2_index', on: :collection
      get 'search', on: :collection
      get 'certificate_to_pdf', on: :member
      post 'esod_matter_link', on: :member
      get 'statistic_filter', on: :collection
      get 'statistic_to_pdf', on: :collection
    end
    resources :exams do
      post 'datatables_index', on: :collection
      get 'select2_index', on: :collection
      get 'examination_cards_to_pdf', on: :member
      get 'examination_protocol_to_pdf', on: :member
      get 'certificates_to_pdf', on: :member
      get 'envelopes_to_pdf', on: :member
      get 'committee_docx', on: :member
      patch 'certificates_generation', on: :member
      post 'esod_matter_link', on: :member
      get 'statistic_filter', on: :collection
      get 'statistic_to_pdf', on: :collection
      get 'statistic2_to_pdf', on: :collection
      post 'force_destroy', on: :member
      post 'download_testportal_pdfs', on: :member
      post 'activate_testportal_tests', on: :member
    end
    resources :examinations do
      post 'datatables_index_exam', on: :collection # for Exam
      get 'examination_card_to_pdf', on: :member
      patch 'certificate_generation', on: :member
      post 'esod_matter_link', on: :member
    end

    resources :charts, only: [] do
      get 'certificates_by_month', on: :collection
      get 'certificates_update_by_month', on: :collection
      get 'certificates_date_of_issue_by_month', on: :collection

      get 'certificates_by_month_division', on: :collection
      get 'certificates_update_by_month_division', on: :collection
      get 'certificates_date_of_issu_by_month_division', on: :collection

      get 'confirmation_logs_by_month', on: :collection
      get 'proposals_by_week_division', on: :collection
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
    post 'datatables_for_select_index', on: :collection
    get 'select2_index', on: :collection
    post 'merge', on: :member
    get 'envelope_to_pdf', on: :member
    get 'history_to_pdf', on: :member
    resources :documents, module: :customers, only: [:create]
  end

  resources :departments
  resources :divisions

  resources :roles do
  	resources :users, only: [:create, :destroy], controller: 'roles/users'
    post 'datatables_index_user', on: :collection # for User
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

  get '/api_teryt/items',                   to: 'api_teryt#items'
  get '/api_teryt/items/:id',               to: 'api_teryt#item_show'
  get '/api_teryt/provinces',               to: 'api_teryt#provinces'
  get '/api_teryt/provinces/:id',           to: 'api_teryt#province_show'


  namespace :esod do
    resources :contractors
    resources :matters do
      post 'datatables_index', on: :collection
      get 'select2_index', on: :collection
      resources :incoming_letters, only: [:show, :create], controller: 'matters/incoming_letters'
      resources :outgoing_letters, only: [:show, :create], controller: 'matters/outgoing_letters'
      resources :internal_letters, only: [:show, :create], controller: 'matters/internal_letters'
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
      #mount Refile.app, at: "attachments", as: :refile_app
      mount Refile.app, at: Refile.mount_point, as: :refile_app
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
        get 'mor_search_by_multi_params', on: :collection
      end
      resources :exams, only: [:index, :show]
      resources :exam_fees, only: [:show] do
        get 'find', on: :collection
      end
      resources :divisions, only: [:index, :show]
      resources :proposals, param: :multi_app_identifier, except: [:new, :edit] do
        get 'grades', on: :member
        get 'grades_with_result', on: :member
      end
      resources :testportal_results, only: [:create]

      get :token, controller: 'base_api'

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
