Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Auth routes
  namespace :auth do
    post 'sign-in', to: 'sessions#sign_in'
    delete 'sign-out', to: 'sessions#sign_out'
    get 'me', to: 'sessions#me'
  end

  # User routes
  resources :users do
    member do
      post :restore
    end
  end

  # Tests routes
  resources :tests do
    member do
      post :restore
    end
  end

  # Courses
  resources :courses do
    member do
      post :restore
    end
  end
end