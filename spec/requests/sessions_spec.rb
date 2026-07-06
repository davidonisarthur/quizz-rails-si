require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user, email: "user@example.com", password: "password123") }

  describe "POST /:locale/session" do
    context "com credenciais válidas" do
      it "autentica o usuário, redireciona e redefine a sessão preservando locale e libras_mode" do
        # 1. Define dados prévios na sessão
        post toggle_libras_mode_path(locale: "pt-BR")
        expect(session[:libras_mode]).to be true

        # 2. Faz o login
        post session_path(locale: "pt-BR"), params: { email: "user@example.com", password: "password123" }

        expect(response).to redirect_to(root_path(locale: "pt-BR"))
        expect(session[:user_id]).to eq(user.id)
        
        # 3. Garante que as preferências de acessibilidade e idioma foram preservadas
        expect(session[:libras_mode]).to be true
        expect(session[:locale].to_s).to eq("pt-BR")
      end
    end

    context "com credenciais inválidas" do
      it "não autentica o usuário e retorna erro 422" do
        post session_path(locale: "pt-BR"), params: { email: "user@example.com", password: "wrongpassword" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe "DELETE /:locale/session" do
    it "limpa a sessão e redireciona o usuário" do
      # Login
      post session_path(locale: "pt-BR"), params: { email: "user@example.com", password: "password123" }
      expect(session[:user_id]).to eq(user.id)

      # Logout
      delete session_path(locale: "pt-BR")
      expect(response).to redirect_to(root_path(locale: "pt-BR"))
      expect(session[:user_id]).to be_nil
    end
  end
end
