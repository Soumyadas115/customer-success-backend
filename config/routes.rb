Rails.application.routes.draw do
  get 'projects/create'
  get 'welcome/index'
  root 'welcome#index'

  get '/projects', to: 'projects#index'
  post '/projects', to: 'projects#create'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :projects, only: [:create], defaults: { format: :json }
  resources :projects, only: [:index], defaults: { format: :json }

  # Defines the root path route ("/")
  # root "posts#index"
end
