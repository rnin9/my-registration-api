Rails.application.routes.draw do
  resources :users do
    member do
      post :restore # POST /users/:id/restore
    end
  end
end