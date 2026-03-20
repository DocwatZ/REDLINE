Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Rooms
  resources :rooms, param: :id do
    member do
      post :join
      delete :leave
    end
    resources :messages, only: [ :create, :update, :destroy ]
    get "livekit_token", to: "livekit#token", as: :livekit_token
  end

  # Direct Messages
  resources :users, only: [ :show ] do
    resource :direct_messages, only: [ :show, :create ]
    post "status", to: "users#update_status", on: :collection
  end

  root to: "rooms#index"
end
