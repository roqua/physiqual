Physiqual::Engine.routes.draw do
  # resources :oauth_session do
  #   collection do
  #     get ':provider/callback' => 'oauth_session#callback', as: 'callback'
  #     get ':provider/authorize' => 'oauth_session#authorize', as: 'authorize'
  #   end
  # end

  scope :export do
    get '/', to: 'export#index'
    resources :service_providers, only: [:show] do
      member do
        scope :raw do

        end
      end
    end
  end

  get 'auth/:provider/authorize', :to => 'sessions#authorize'
  get 'auth/:provider/callback',  :to => 'sessions#create'
  get 'auth/failure',             :to => 'sessions#failure'
end
