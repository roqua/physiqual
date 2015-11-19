Physiqual::Engine.routes.draw do
  # resources :oauth_session do
  #   collection do
  #     get ':provider/callback' => 'oauth_session#callback', as: 'callback'
  #     get ':provider/authorize' => 'oauth_session#authorize', as: 'authorize'
  #   end
  # end

  resources :exports, only: [:index]
  get 'export/providers/:provider/data_source/:data_source', :to => 'exports#raw'


  get 'auth/:provider/authorize', :to => 'sessions#authorize'
  get 'auth/:provider/callback',  :to => 'sessions#create'
  get 'auth/failure',             :to => 'sessions#failure'
end
