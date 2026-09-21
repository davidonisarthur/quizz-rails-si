require "rails_helper"

RSpec.describe "Study", type: :request do
  it "lists Portuguese study modules" do
    get study_path(locale: "pt-BR")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Estudo guiado")
    expect(response.body).to include("Conteúdos para estudar")
    expect(response.body).to include("Máquina de Turing")
    expect(response.body).to include(study_topic_path("turing-machine", locale: "pt-BR"))
  end

  it "renders the Turing machine study module in English" do
    get study_topic_path("turing-machine", locale: "en")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Guided study")
    expect(response.body).to include("The history of the Turing machine")
    expect(response.body).to include("Simple rules, precise steps")
    expect(response.body).to include("Labels in the diagram")
    expect(response.body).to include("finite control keeps the current state")
    expect(response.body).to include("Why it matters")
    expect(response.body).to include("A tape in motion")
    expect(response.body).to include("Next step")
  end

  it "uses the reduced visual content when LIBRAS mode is enabled" do
    post toggle_libras_mode_path(locale: "pt-BR")
    get study_topic_path("turing-machine", locale: "pt-BR")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Modo LIBRAS · conteúdo visual")
    expect(response.body).to include("Alan Turing e uma ideia nova")
    expect(response.body).to include("Tradução: Tape = fita")
    expect(response.body).to include("q0, q1 e q2 são estados")
    expect(response.body).to include("alan-turing-1951")
    expect(response.body).not_to include("Antes dos computadores modernos existirem")
  end

  it "does not expose unknown study modules" do
    get study_topic_path("unknown-topic", locale: "pt-BR")

    expect(response).to have_http_status(:not_found)
  end

  it "lists and renders only published teacher-created study content" do
    published_module = create(:study_module, published: true, title_pt: "Introdução à lógica", summary_pt: "Um resumo novo", content_pt: "Explicação longa.", libras_content_pt: "Explicação curta.")
    draft_module = create(:study_module, published: false, title_pt: "Rascunho secreto")

    get study_path(locale: "pt-BR")
    expect(response.body).to include("Introdução à lógica")
    expect(response.body).not_to include(draft_module.title_pt)

    get study_topic_path(published_module.slug, locale: "pt-BR")
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Explicação longa.")

    post toggle_libras_mode_path(locale: "pt-BR")
    get study_topic_path(published_module.slug, locale: "pt-BR")
    expect(response.body).to include("Explicação curta.")
    expect(response.body).not_to include("Explicação longa.")

    get study_topic_path(draft_module.slug, locale: "pt-BR")
    expect(response).to have_http_status(:not_found)
  end
end
