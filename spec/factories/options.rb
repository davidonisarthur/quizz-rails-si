FactoryBot.define do
  factory :option do
    association :question
    text_pt { "15" }
    text_en { "15" }
  end
end
