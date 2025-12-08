Rails.application.routes.draw do
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
end