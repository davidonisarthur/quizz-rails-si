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
    expect(response.body).to include("alan-turing-1951")
    expect(response.body).not_to include("Antes dos computadores modernos existirem")
  end

  it "does not expose unknown study modules" do
    get study_topic_path("unknown-topic", locale: "pt-BR")

    expect(response).to have_http_status(:not_found)
  end
end
