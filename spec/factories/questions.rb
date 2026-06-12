FactoryBot.define do
  factory :question do
    quiz_module { nil }
    body_pt { "MyText" }
    body_en { "MyText" }
    context_pt { "MyText" }
    context_en { "MyText" }
    correct_index { 1 }
    libras_video_url { "MyString" }
  end
end
