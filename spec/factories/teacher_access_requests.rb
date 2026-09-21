FactoryBot.define do
  factory :teacher_access_request do
    association :user
    status { "pending" }
  end
end
