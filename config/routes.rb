Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "posts#index"

  # Session routes for login/logout
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # User routes
  resources :users, except: [:destroy] do
    member do
      get :profile
    end
  end

  # Post routes
  resources :posts do
    collection do
      get :filter
    end
    member do
      get :download
    end
    resources :comments, only: [:create, :destroy]
  end

  # Admin routes
  namespace :admin do
    get "reports/search_logs", to: "reports#search_logs"
    get "reports/export", to: "reports#export"
    post "reports/calculate", to: "reports#calculate"
  end

  # API endpoints
  namespace :api do
    namespace :v1 do
      resources :posts, only: [:index, :show]
    end
  end
end
