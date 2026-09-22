require 'rails_helper'

RSpec.describe "About", type: :request do
  describe "GET /:locale/about" do
    it "renders the about page successfully in Portuguese" do
      get about_path(locale: "pt-BR")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sobre o PrimoQuiz")
      expect(response.body).to include("Iniciação Científica")
      expect(response.body).to include("Professora Dra. Renata da Silva Dessbesel")
      expect(response.body).to match(%r{src="/assets/utfpr-logo-[^"]+\.png"})
    end

    it "renders the about page successfully in English" do
      get about_path(locale: "en")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("About PrimoQuiz")
      expect(response.body).to include("Scientific Initiation")
      expect(response.body).to include("Professor Dr. Renata da Silva Dessbesel")
    end
  end
end
