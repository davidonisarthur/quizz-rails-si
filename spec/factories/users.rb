FactoryBot.define do
  factory :user do
    name { "Arthur" }
    sequence(:email) { |n| "usuario#{n}@email.com" }
    password { "senha123" }
  end
end
