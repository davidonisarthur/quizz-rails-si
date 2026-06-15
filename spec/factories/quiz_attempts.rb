FactoryBot.define do
  factory :quiz_attempt do
    association :user
    association :quiz_module
    score { 3 }
  end
end
