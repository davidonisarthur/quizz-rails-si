FactoryBot.define do
  factory :quiz_response do
    association :quiz_attempt
    association :question
    selected_index { 0 }
    correct { false }
  end
end
