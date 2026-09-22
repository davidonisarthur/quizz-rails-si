require 'rails_helper'

RSpec.describe "I18n Translations", type: :request do
  let!(:quiz_module) { create(:quiz_module, slug: "o-que-e-primo", title_pt: "Módulo 1", title_en: "Module 1") }
  let!(:question) { create(:question, quiz_module: quiz_module) }
  let!(:user) { create(:user, name: "Maria", email: "maria@example.com", password: "password123") }

  describe "Navegação e Layout Bilíngue" do
    it "renderiza termos em português quando locale é pt-BR" do
      get root_path(locale: "pt-BR")

      expect(response.body).to include("Entrar")
      expect(response.body).to include("Estudo")
      expect(response.body).to include("Sobre")
      expect(response.body).to include("Tema")
      expect(response.body).to include("Pular para o conteúdo")
      expect(response.body).to include('id="main-content"')
    end

    it "renderiza termos em inglês quando locale é en" do
      get root_path(locale: "en")

      expect(response.body).to include("Sign in")
      expect(response.body).to include("Study")
      expect(response.body).to include("About")
      expect(response.body).to include("Theme")
      expect(response.body).to include("Skip to content")
    end

    it "não expõe mais a rota pública de ranking" do
      get "/pt-BR/ranking"

      expect(response).to have_http_status(:not_found)
    end

    it "renderiza botão de Sair em português e Sign out em inglês quando logado" do
      post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }
      get root_path(locale: "pt-BR")
      expect(response.body).to include("Sair")

      get root_path(locale: "en")
      expect(response.body).to include("Sign out")
    end
  end

  describe "Página Inicial" do
    it "renderiza status e botão em português no pt-BR" do
      get root_path(locale: "pt-BR")
      expect(response.body).to include("Disponível")
      expect(response.body).to include("Jogar")
    end

    it "renderiza status e botão em inglês no en" do
      get root_path(locale: "en")
      expect(response.body).to include("Available")
      expect(response.body).to include("Play")
    end
  end

  describe "Página de módulos" do
    it "usa os textos centralizados para os dois idiomas" do
      get quiz_modules_path(locale: "pt-BR")
      expect(response.body).to include("Módulos de Quiz")

      get quiz_modules_path(locale: "en")
      expect(response.body).to include("Quiz Modules")
    end
  end

  describe "Autenticação (Login e Cadastro)" do
    it "renderiza página de login traduzida para pt-BR e en" do
      get new_session_path(locale: "pt-BR")
      expect(response.body).to include("Entrar")
      expect(response.body).to include("Não tem conta?")
      expect(response.body).to include("Cadastre-se")

      get new_session_path(locale: "en")
      expect(response.body).to include("Sign in")
      expect(response.body).to include("Don&#39;t have an account?")
      expect(response.body).to include("Sign up")
    end

    it "renderiza formulário de cadastro traduzido para pt-BR e en" do
      get new_user_path(locale: "pt-BR")
      expect(response.body).to include("Criar Conta")
      expect(response.body).to include("Nome completo")
      expect(response.body).to include("Já possui uma conta?")

      get new_user_path(locale: "en")
      expect(response.body).to include("Create Account")
      expect(response.body).to include("Full name")
      expect(response.body).to include("Already have an account?")
    end
  end

  describe "Perfil do Usuário" do
    before do
      post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }
    end

    it "renderiza progresso e estado inicial traduzidos" do
      get profile_path(locale: "pt-BR")
      expect(response.body).to include("Meu progresso")
      expect(response.body).to include("Explorar conteúdos de estudo")
      expect(response.body).not_to include("Módulos concluídos")

      get profile_path(locale: "en")
      expect(response.body).to include("My progress")
      expect(response.body).to include("Explore study topics")
      expect(response.body).not_to include("Completed modules")
    end

    it "formata a data das tentativas nos dois idiomas" do
      attempt = create(:quiz_attempt, user: user, quiz_module: quiz_module, created_at: Time.zone.local(2026, 1, 2, 15, 30))

      get profile_path(locale: "pt-BR")
      expect(response.body).to include(I18n.l(attempt.created_at, format: :short, locale: :"pt-BR"))

      get profile_path(locale: "en")
      expect(response.body).to include(I18n.l(attempt.created_at, format: :short, locale: :en))
    end

    it "mostra progresso, melhor resultado e módulos pendentes" do
      completed_module = create(:quiz_module, position: 1, title_pt: "Módulo concluído", title_en: "Completed module")
      pending_module = create(:quiz_module, position: 2, title_pt: "Próximo módulo", title_en: "Next module")
      create(:question, quiz_module: completed_module, position: 1)
      create(:question, quiz_module: pending_module, position: 1)
      create(:quiz_attempt, user: user, quiz_module: completed_module, score: 1, created_at: 2.days.ago)
      create(:quiz_attempt, user: user, quiz_module: completed_module, score: 0, created_at: 1.day.ago)

      get profile_path(locale: "pt-BR")

      expect(response.body).to include("1 de 3 módulos concluídos")
      expect(response.body).to include("Próximo módulo")
      expect(response.body).to include("Melhor resultado")
      expect(response.body).to include("100%")
      expect(response.body).to include("Última tentativa")
    end

    it "mostra o progresso dos conteúdos de estudo" do
      StudyProgress.create!(user: user, study_slug: "turing-machine", started_at: Time.current, last_accessed_at: Time.current, completed_at: Time.current)

      get profile_path(locale: "pt-BR")

      expect(response.body).to include("Progresso nos estudos")
      expect(response.body).to include("Máquina de Turing")
      expect(response.body).to include("1 de 1 conteúdos concluídos")
    end

    it "does not show progress whose study content is no longer available" do
      StudyProgress.create!(user: user, study_slug: "conteudo-removido", started_at: Time.current, last_accessed_at: Time.current)

      get profile_path(locale: "pt-BR")

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("conteudo-removido")
    end
  end

  describe "Resultado do Quiz" do
    let!(:attempt) { create(:quiz_attempt, user: user, quiz_module: quiz_module, score: 3) }

    before do
      post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }
    end

    it "renderiza títulos e botões traduzidos no resultado" do
      get result_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      expect(response.body).to include("Quiz Finalizado!")
      expect(response.body).to include("Sua pontuação:")
      expect(response.body).to include("Voltar ao início")
      expect(response.body).to include("Tentar novamente")

      get result_quiz_module_path(slug: quiz_module.slug, locale: "en")
      expect(response.body).to include("Quiz Completed!")
      expect(response.body).to include("Your score:")
      expect(response.body).to include("Back to home")
      expect(response.body).to include("Try again")
    end
  end
end
