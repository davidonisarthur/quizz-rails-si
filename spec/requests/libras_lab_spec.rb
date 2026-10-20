require "rails_helper"

RSpec.describe "LIBRAS computer vision laboratory", type: :request do
  it "renders the local webcam prototype in Portuguese" do
    get libras_lab_path(locale: "pt-BR")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Laboratório de visão computacional")
    expect(response.body).to include('data-controller="hand-gesture"')
    expect(response.body).to include("gesture_01")
    expect(response.body).to include("Iniciar webcam")
    expect(response.body).to include("A imagem da webcam não é enviada ao servidor")
    expect(response.body).to include("Acompanhe a configuração")
    expect(response.body).to include("Últimas confirmações")
    expect(response.body).to include('data-hand-gesture-target="framingGuide"')
  end

  it "renders the prototype in English" do
    get libras_lab_path(locale: "en")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Computer vision laboratory")
    expect(response.body).to include("Start webcam")
    expect(response.body).to include("Follow the configuration")
    expect(response.body).to include("Latest confirmations")
  end
end
