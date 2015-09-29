FactoryGirl.define do
  factory :token, class: Physiqual::Token do
    token 'the_token'
    refresh_token 'the_refresh_token'
    valid_until Time.now.in_time_zone
    association :user, strategy: :build

    trait :mock do
      type 'mock_token'
    end

    trait :google do
      type Physiqual::GoogleToken.csrf_token
    end

    trait :fitbit do
      type Physiqual::FitbitToken.csrf_token
    end

    factory :mock_token, traits: [:mock]
    factory :fitbit_token, class: Physiqual::FitbitToken, traits: [:fitbit]
    factory :google_token, class: Physiqual::GoogleToken, traits: [:google]
  end
end
