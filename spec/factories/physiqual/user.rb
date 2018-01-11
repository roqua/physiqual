FactoryBot.define do
  factory :physiqual_user, class: Physiqual::User do
    user_id 'user_id123'

    trait :second do
      user_id 'user_id456'
    end
  end
end
