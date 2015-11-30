Physiqual::Engine.routes.draw do
  resources :exports, only: [:index]
  get 'exports/providers/:provider/data_source/:data_source', :to => 'exports#raw'

  get 'auth/:provider/authorize', :to => 'sessions#authorize', as: 'authorize'
  get 'auth/:provider/callback',  :to => 'sessions#create', as: 'callback'
  get 'auth/failure',             :to => 'sessions#failure', as: 'failure'

  get 'test', to: 'test_login#index'
  post 'test', to: 'test_login#create'
  delete 'test', to: 'test_login#destroy'
end
