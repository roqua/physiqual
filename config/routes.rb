Physiqual::Engine.routes.draw do
  resources :oauth_session do
    collection do
      get ':provider/callback' => 'oauth_session#callback', as: 'callback'
      get ':provider/authorize' => 'oauth_session#authorize', as: 'authorize'
    end
  end
end
