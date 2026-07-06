require 'rails_helper'

RSpec.describe "About", type: :request do
  describe "GET /:locale/about" do
    it "renders the about page successfully in Portuguese" do
      get about_path(locale: "pt-BR")
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sobre o PrimoQuiz")
      expect(response.body).to include("Iniciação Científica")
    end

    it "renders the about page successfully in English" do
      get about_path(locale: "en")
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("About PrimoQuiz")
      expect(response.body).to include("Scientific Initiation")
    end
  end
end
