FactoryBot.define do
  factory :question do
    association :quiz_module
    body_pt { "Qual destes números é primo?" }
    body_en { "Which of these numbers is prime?" }
    context_pt { "Um número primo tem exatamente 2 divisores." }
    context_en { "A prime number has exactly 2 divisors." }
    correct_index { 1 }
    libras_video_url { "https://youtube.com/watch?v=exemplo" }
  end
end
