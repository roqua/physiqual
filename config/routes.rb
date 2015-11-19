Physiqual::Engine.routes.draw do
  resources :exports, only: [:index]
  get 'exports/providers/:provider/data_source/:data_source', :to => 'exports#raw'

  get 'auth/:provider/authorize', :to => 'sessions#authorize'
  get 'auth/:provider/callback',  :to => 'sessions#create'
  get 'auth/failure',             :to => 'sessions#failure'
end
