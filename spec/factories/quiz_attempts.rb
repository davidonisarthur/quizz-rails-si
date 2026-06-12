FactoryBot.define do
  factory :quiz_attempt do
    user { nil }
    quiz_module { nil }
    score { 1 }
  end
end
