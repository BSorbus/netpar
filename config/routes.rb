Rails.application.routes.draw do


  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :users do
    resources :documents, module: :users, only: [:create]
    post 'datatables_index', on: :collection
    patch 'lock', on: :member
    patch 'unlock', on: :member
  end


  scope ':category_service', constraints: { category_service: /[lmr]/ } do
    resources :certificates do
      post 'datatables_index', on: :collection
      post 'datatables_index_exam', on: :collection # for Exam
      get 'certificate_to_pdf', on: :member
    end
    resources :exams do
      post 'datatables_index', on: :collection
      get 'select2_index', on: :collection
      get 'certificates_to_pdf', on: :member
      get 'examination_cards_to_pdf', on: :member
      get 'examination_protocol_to_pdf', on: :member
      patch 'generating_certificates', on: :member
    end
    resources :examinations do
      post 'datatables_index_exam', on: :collection # for Exam
      get 'examination_card_to_pdf', on: :member
      patch 'generating_certificate', on: :member
    end
  end



  resources :certificates, only: [] do
    resources :documents, module: :certificates, only: [:create]
  end

  resources :exams, only: [] do
    resources :documents, module: :exams, only: [:create]
  end

  resources :examinations, only: [] do
    resources :documents, module: :examinations, only: [:create]
  end

  resources :customers do
    post 'datatables_index', on: :collection
    get 'select2_index', on: :collection
    post 'merge', on: :member
    resources :documents, module: :customers, only: [:create]
  end

  resources :individuals do
    post 'datatables_index', on: :collection
    resources :documents, module: :individuals, only: [:create]
  end

  resources :departments

  resources :roles do
  	resources :users, only: [:create, :destroy], controller: 'roles/users'
  end

  #resources :documents, only: [:destroy]
  resources :documents, only: [:show, :destroy]

  resources :works, only: [:index] do
    post 'datatables_index', on: :collection # for User
    post 'datatables_index_trackable', on: :collection # for Trackable
    post 'datatables_index_user', on: :collection # for User
  end

  root to: 'visitors#index'

end
