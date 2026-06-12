FactoryBot.define do
  factory :feedback do
    question { nil }
    kind { "MyString" }
    body_pt { "MyText" }
    body_en { "MyText" }
  end
end
