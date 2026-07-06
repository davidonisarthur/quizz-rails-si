require 'rails_helper'

RSpec.describe "Quizzes", type: :request do
  let!(:quiz_module) { create(:quiz_module, slug: "o-que-e-primo") }
  let!(:q1) { create(:question, quiz_module: quiz_module, correct_index: 1, body_pt: "Qual destes números é primo?", libras_video_url: "https://youtube.com/watch?v=exemplo") }
  let!(:q2) { create(:question, quiz_module: quiz_module, correct_index: 0, body_pt: "O número 1 é primo?", libras_video_url: "") }
  
  let!(:o1_q1) { create(:option, question: q1, text_pt: "15") }
  let!(:o2_q1) { create(:option, question: q1, text_pt: "17") } # Correct choice for q1 is index 1
  let!(:o1_q2) { create(:option, question: q2, text_pt: "Sim") } # Correct choice for q2 is index 0
  
  let!(:f_correct_q1) { create(:feedback, question: q1, kind: "correct", body_pt: "Parabéns, o 17 é primo!") }
  let!(:f_incorrect_q1) { create(:feedback, question: q1, kind: "incorrect", body_pt: "Tente novamente, 15 não é primo!") }
  let!(:f_correct_q2) { create(:feedback, question: q2, kind: "correct", body_pt: "Muito bem, 1 não é primo!") }
  let!(:f_incorrect_q2) { create(:feedback, question: q2, kind: "incorrect", body_pt: "Errado, 1 não é primo.") }

  describe "GET /:locale/quiz_modules/:slug/play" do
    it "inicia o quiz com a primeira questão quando não passamos question_index" do
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      
      expect(response).to have_http_status(:ok)
      expect(session[:quiz]).to eq({
        "module_id" => quiz_module.id,
        "question_index" => 0,
        "score" => 0
      })
      expect(response.body).to include("Qual destes números é primo?")
      expect(response.body).to include("Questão 1 de 2")
      expect(response.body).to include("0%")
    end

    it "avança para a questão solicitada se o quiz já estiver em progresso na sessão" do
      # Primeiro, iniciamos o quiz na sessão
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      
      # Em seguida, solicitamos o question_index 1 (próxima questão)
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 1)
      
      expect(response).to have_http_status(:ok)
      expect(session[:quiz]["question_index"]).to eq(1)
      expect(response.body).to include("O número 1 é primo?")
      expect(response.body).to include("Questão 2 de 2")
      expect(response.body).to include("50%")
    end

    it "mantém o progresso do quiz se recarregarmos a página sem passar question_index" do
      # Primeiro, iniciamos o quiz na sessão
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      
      # Em seguida, solicitamos o question_index 1
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 1)
      expect(session[:quiz]["question_index"]).to eq(1)

      # Agora, recarregamos sem passar question_index e validamos se manteve no índice 1
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      expect(session[:quiz]["question_index"]).to eq(1)
    end

    it "redireciona para os resultados se o question_index estiver fora dos limites (nil question)" do
      # Inicializa o quiz
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      
      # Solicita índice inexistente (2)
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 2)
      
      expect(response).to redirect_to(result_quiz_module_path(quiz_module.slug, locale: "pt-BR"))
    end
  end

  describe "POST /:locale/quiz_modules/:slug/answer" do
    before do
      # Inicializa o quiz na sessão antes de enviar a resposta
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
    end

    it "incrementa score e atualiza o index da sessão quando a resposta está correta" do
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q1.id)
      
      expect(response).to have_http_status(:ok)
      expect(session[:quiz]["score"]).to eq(1)
      expect(session[:quiz]["question_index"]).to eq(1)
      expect(response.body).to include("Parabéns, o 17 é primo!")
      expect(response.body).to include("Questão 1 de 2")
      expect(response.body).to include("50%")
    end

    it "não incrementa score mas atualiza o index da sessão quando a resposta está incorreta" do
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 0, question_id: q1.id)
      
      expect(response).to have_http_status(:ok)
      expect(session[:quiz]["score"]).to eq(0)
      expect(session[:quiz]["question_index"]).to eq(1)
      expect(response.body).to include("Tente novamente, 15 não é primo!")
      expect(response.body).to include("Questão 1 de 2")
      expect(response.body).to include("50%")
    end

    it "inclui link para ver resultado quebrando o frame turbo (data-turbo-frame='_top') quando for a última questão" do
      # Avança para a última questão (índice 1)
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 1)
      
      # Responde à última questão
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 0, question_id: q2.id)
      
      expect(response.body).to include("data-turbo-frame=\"_top\"")
      expect(response.body).to include("Ver resultado")
    end
  end

  describe "POST /:locale/quiz_modules/:slug/answer - situações excepcionais" do
    it "redireciona para o play se a sessão estiver em branco" do
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 0)
      expect(response).to redirect_to(play_quiz_module_path(quiz_module.slug, locale: "pt-BR"))
    end

    it "redireciona para o play se a pergunta correspondente ao index na sessão não existir" do
      # Inicializa a sessão
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      
      # Força a definição de um index alto/inválido
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 999)
      
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 0)
      expect(response).to redirect_to(play_quiz_module_path(quiz_module.slug, locale: "pt-BR"))
    end

    it "usa o feedback fallback se nenhum feedback correspondente estiver no banco de dados" do
      q1.feedbacks.destroy_all
      
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q1.id)
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sem feedback cadastrado.")
    end
  end

  describe "GET /:locale/quiz_modules/:slug/result" do
    it "exibe o resultado e limpa a sessão do quiz para convidados" do
      # Inicializa e joga
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      # Responde Q1 (correto)
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q1.id)
      # Responde Q2 (incorreto, correto seria 0)
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q2.id)

      get result_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("1") # Mostra score
      expect(response.body).to include("2") # Mostra total
      expect(session[:quiz]).to be_nil
    end

    it "registra um QuizAttempt se houver um usuário autenticado ao finalizar" do
      user = create(:user)
      # Simula login definindo user_id na sessão do controller
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      # Responde Q1
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q1.id)

      expect {
        # Responde Q2 (finaliza o quiz)
        post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q2.id)
      }.to change(QuizAttempt, :count).by(1)

      attempt = QuizAttempt.last
      expect(attempt.user).to eq(user)
      expect(attempt.quiz_module).to eq(quiz_module)
      expect(attempt.score).to eq(1)

      # Agora acessa o resultado
      get result_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("1")
      expect(response.body).to include("2")
    end
  end

  describe "POST /:locale/libras_mode/toggle" do
    it "toggles LIBRAS mode session variable and redirects back" do
      # Make a first request to initialize session
      get root_path(locale: "pt-BR")
      expect(session[:libras_mode]).to be_nil

      # Toggle on
      post toggle_libras_mode_path(locale: "pt-BR")
      expect(response).to redirect_to(root_path)
      expect(session[:libras_mode]).to be true

      # Toggle off
      post toggle_libras_mode_path(locale: "pt-BR")
      expect(session[:libras_mode]).to be false
    end
  end

  describe "LIBRAS video button visibility on play page" do
    it "does not show the LIBRAS video button if LIBRAS mode is disabled" do
      # LIBRAS mode disabled by default
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 0)
      expect(response.body).not_to include("Assistir em LIBRAS")
    end

    it "shows the LIBRAS video button if LIBRAS mode is enabled and question has embed url" do
      # Initialize play session
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")

      # Enable LIBRAS mode in session
      post toggle_libras_mode_path(locale: "pt-BR")
      expect(session[:libras_mode]).to be true

      # Access play page for q1 (index 0, which has video)
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 0)
      
      expect(response.body).to include("Assistir em LIBRAS")
      expect(response.body).to include("https://www.youtube.com/embed/exemplo")
    end

    it "does not show the LIBRAS video button if question does not have a video" do
      # Initialize play session
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")

      # Enable LIBRAS mode in session
      post toggle_libras_mode_path(locale: "pt-BR")
      expect(session[:libras_mode]).to be true

      # Access play page for q2 (index 1, which has empty video url)
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 1)
      
      expect(response.body).not_to include("Assistir em LIBRAS")
    end
  end
end
