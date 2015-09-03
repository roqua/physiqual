FactoryGirl.define do
  factory :token do
    token 'the_token'
    refresh_token 'the_refresh_token'
    valid_until Time.now.in_time_zone
    user

    trait :mock do
      type 'mock_token'
    end

    trait :google do
      type GoogleToken.csrf_token
    end

    trait :fitbit do
      type FitbitToken.csrf_token
    end

    factory :fitbit_token, traits: [:fitbit]
    factory :google_token, traits: [:google]
  end
end
