FactoryBot.define do
  factory :user do
    name { "Arthur" }
    sequence(:email) { |n| "usuario#{n}@email.com" }
    password { "senha123" }

    trait :teacher do
      role { "teacher" }
    end

    trait :admin do
      role { "admin" }
    end
  end
end
