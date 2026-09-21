FactoryBot.define do
  factory :study_module do
    association :created_by, factory: %i[user teacher]
    sequence(:title_pt) { |n| "Conteúdo #{n}" }
    sequence(:title_en) { |n| "Content #{n}" }
    summary_pt { "Resumo do conteúdo" }
    summary_en { "Content summary" }
    content_pt { "Explicação completa em português." }
    content_en { "Complete explanation in English." }
    libras_content_pt { "Texto curto para Libras." }
    libras_content_en { "Short text for Libras." }
    sequence(:slug) { |n| "conteudo-#{n}" }
    sequence(:position)
    published { false }
  end
end
