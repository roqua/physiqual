Rails.application.routes.draw do
  mount Physiqual::Engine => '/physiqual'
  root to: 'physiqual/test_login#index'
end
