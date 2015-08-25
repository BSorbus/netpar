Rails.application.routes.draw do


  devise_for :users
  resources :users do
    post 'datatables_index', on: :collection
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
      get 'certificate_to_pdf', on: :member
    end
    resources :examinations do
      post 'datatables_index_exam', on: :collection # for Exam
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

  #resources :documents, only: [:destroy]
  resources :documents, only: [:show, :destroy]


  resources :departments

  resources :roles do
  	resources :users, only: [:create, :destroy], controller: 'roles/users' do
  	end
  end

  root to: 'visitors#index'

end
