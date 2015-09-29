module Physiqual
  FactoryGirl.define do
    factory :token do
      token 'the_token'
      refresh_token 'the_refresh_token'
      valid_until Time.now.in_time_zone
      association :user, strategy: :build
  
      trait :mock do
        type 'mock_token'
      end
  
      trait :google do
        type GoogleToken.csrf_token
      end
  
      trait :fitbit do
        type FitbitToken.csrf_token
      end
  
      factory :mock_token, traits: [:mock]
      factory :fitbit_token, class: FitbitToken, traits: [:fitbit]
      factory :google_token, class: GoogleToken, traits: [:google]
    end
  end
end
