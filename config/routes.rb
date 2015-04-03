Rails.application.routes.draw do

  resources :sessions
  resources :users
  resources :mains
  match 'auth/:provider/callback', to: 'sessions#create',via: [:get]
  match 'auth/failure', to: redirect('/'), via: [:get]
  match 'signout', to: 'sessions#destroy', as: 'signout',via: [:get]

  namespace(:admin){
    resources :ad_accounts
    resources :events
  }

  namespace(:api){
    resources :users
  }

  # You can have the root of your site routed with "root"
  root 'mains#index'

end
