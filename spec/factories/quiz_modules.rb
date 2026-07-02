FactoryBot.define do
  factory :quiz_module do
    title_pt { "O que é primo?" }
    title_en { "What is a prime?" }
    sequence(:slug) { |n| "modulo-#{n}" }
    unlocked { true }
  end
end
