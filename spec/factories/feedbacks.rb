FactoryBot.define do
  factory :feedback do
    association :question
    kind { "correct" }
    body_pt { "17 só divide por 1 e 17." }
    body_en { "17 divides only by 1 and 17." }
  end
end
