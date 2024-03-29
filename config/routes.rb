Rails.application.routes.draw do
  resources :museum_registration_requests do
    member do
      patch :update_registration_status
    end
  end
  devise_for :users
  resources :museums
  resources :users
  # get 'home/index' # could be a route for the home if necessary
  root 'home#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
