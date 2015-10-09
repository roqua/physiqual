FactoryGirl.define do
  factory :physiqual_token, class: Physiqual::Token do
    token 'the_token'
    refresh_token 'the_refresh_token'
    valid_until 1.hour.from_now.in_time_zone
    association :physiqual_user, strategy: :build

    trait :mock do
      type 'mock_token'
    end

    trait :google do
      type Physiqual::GoogleToken
    end

    trait :fitbit do
      type Physiqual::FitbitToken
    end

    factory :mock_token, traits: [:mock]
    factory :fitbit_token, class: Physiqual::FitbitToken, parent: :physiqual_token, traits: [:fitbit]
    factory :google_token, class: Physiqual::GoogleToken, parent: :physiqual_token, traits: [:google]
  end
end
