require 'rails_helper'

RSpec.describe "Quizzes", type: :request do
  let!(:quiz_module) { create(:quiz_module, slug: "o-que-e-primo") }
  let!(:q1) { create(:question, quiz_module: quiz_module, correct_index: 1, body_pt: "Qual destes números é primo?", libras_video_url: "https://youtube.com/watch?v=exemplo") }
  let!(:q2) { create(:question, quiz_module: quiz_module, correct_index: 0, body_pt: "O número 1 é primo?", libras_video_url: "") }

  let!(:o1_q1) { create(:option, question: q1, text_pt: "15") }
  let!(:o2_q1) { create(:option, question: q1, text_pt: "17") } # Correct choice for q1 is index 1
  let!(:o1_q2) { create(:option, question: q2, text_pt: "Sim") } # Correct choice for q2 is index 0
  let!(:o2_q2) { create(:option, question: q2, text_pt: "Não") }

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

    it "ignora question_index informado na URL e preserva o estado da sessão" do
      # Primeiro, iniciamos o quiz na sessão
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")

      # A progressão é definida somente depois de uma resposta válida.
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 1)

      expect(response).to have_http_status(:ok)
      expect(session[:quiz]["question_index"]).to eq(0)
      expect(response.body).to include("Qual destes números é primo?")
      expect(response.body).to include("Questão 1 de 2")
      expect(response.body).to include("0%")
    end

    it "mantém o progresso do quiz se recarregarmos a página sem passar question_index" do
      # Primeiro, iniciamos o quiz na sessão
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")

      # Uma resposta válida avança o estado da sessão.
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q1.id)
      expect(session[:quiz]["question_index"]).to eq(1)

      # Agora, recarregamos sem passar question_index e validamos se manteve no índice 1
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      expect(session[:quiz]["question_index"]).to eq(1)
    end

    it "não aceita índices fora dos limites informados pela URL" do
      # Inicializa o quiz
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")

      # Solicita índice inexistente (2)
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 2)

      expect(response).to have_http_status(:ok)
      expect(session[:quiz]["question_index"]).to eq(0)
      expect(response.body).to include("Qual destes números é primo?")
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
      # Responder a primeira questão é a única forma de avançar para a última.
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q1.id)

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

    it "rejeita uma resposta sem alternativa, sem alterar o progresso" do
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")

      expect {
        post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_id: q1.id)
      }.not_to change { session[:quiz]["score"] }

      expect(response).to redirect_to(play_quiz_module_path(quiz_module.slug, locale: "pt-BR"))
      expect(session[:quiz]["question_index"]).to eq(0)
    end

    it "rejeita alternativas não numéricas ou fora do intervalo" do
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")

      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: "invalida", question_id: q1.id)
      expect(response).to redirect_to(play_quiz_module_path(quiz_module.slug, locale: "pt-BR"))
      expect(session[:quiz]["score"]).to eq(0)

      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 99, question_id: q1.id)
      expect(response).to redirect_to(play_quiz_module_path(quiz_module.slug, locale: "pt-BR"))
      expect(session[:quiz]["score"]).to eq(0)
    end

    it "não permite responder novamente uma questão já concluída" do
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q1.id)
      expect(session[:quiz]["score"]).to eq(1)

      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 0)
      expect(session[:quiz]["question_index"]).to eq(1)

      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q1.id)
      expect(response).to redirect_to(play_quiz_module_path(quiz_module.slug, locale: "pt-BR", question_index: 1))
      expect(session[:quiz]["score"]).to eq(1)
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
        .and change(QuizResponse, :count).by(2)

      attempt = QuizAttempt.last
      expect(attempt.user).to eq(user)
      expect(attempt.quiz_module).to eq(quiz_module)
      expect(attempt.score).to eq(1)
      expect(attempt.quiz_responses.order(:question_id).pluck(:question_id, :selected_index, :correct)).to contain_exactly(
        [ q1.id, 1, true ],
        [ q2.id, 1, false ]
      )

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

  describe "LIBRAS translation button and VLibras visibility on play page" do
    it "does not show the LIBRAS translation buttons if LIBRAS mode is disabled" do
      # LIBRAS mode disabled by default
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")
      expect(response.body).not_to include("Traduzir em LIBRAS (Avatar 3D)")
    end

    it "shows the VLibras 3D Avatar translation button when LIBRAS mode is enabled" do
      # Initialize play session
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")

      # Enable LIBRAS mode in session
      post toggle_libras_mode_path(locale: "pt-BR")
      expect(session[:libras_mode]).to be true

      # Access play page for q1 (index 0)
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", question_index: 0)

      expect(response.body).to include("Traduzir em LIBRAS (Avatar 3D)")
      expect(response.body).to include('data-controller="vlibras"')
      expect(response.body).to include('data-action="click->vlibras#translate"')
      expect(response.body).to include('data-vlibras-text-value="Qual destes números é primo? Um número primo tem exatamente 2 divisores."')
      expect(response.body).to include("Vídeo Gravado em LIBRAS")
    end

    it "shows VLibras 3D translation button even if question does not have a pre-recorded video" do
      # Initialize play session
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")

      # Enable LIBRAS mode in session
      post toggle_libras_mode_path(locale: "pt-BR")
      expect(session[:libras_mode]).to be true

      # Answer q1 to advance to q2 (which has no pre-recorded video).
      post answer_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR", option_index: 1, question_id: q1.id)
      get play_quiz_module_path(slug: quiz_module.slug, locale: "pt-BR")

      expect(response.body).to include("Traduzir em LIBRAS (Avatar 3D)")
      expect(response.body).to include('data-vlibras-text-value="O número 1 é primo? Um número primo tem exatamente 2 divisores."')
      expect(response.body).not_to include("Vídeo Gravado em LIBRAS")
    end

    it "renders the English question and context inside data-vlibras-text-value when locale is en" do
      get play_quiz_module_path(slug: quiz_module.slug, locale: "en")
      post toggle_libras_mode_path(locale: "en")
      get play_quiz_module_path(slug: quiz_module.slug, locale: "en")

      expect(response.body).to include("Translate into LIBRAS (3D Avatar)")
      expect(response.body).to include('data-controller="vlibras"')
      expect(response.body).to include('data-action="click->vlibras#translate"')
      expect(response.body).to include('data-vlibras-text-value="Which of these numbers is prime? A prime number has exactly 2 divisors."')
    end
  end

  describe "Proteção de módulos bloqueados e vazios" do
    let!(:locked_module) { create(:quiz_module, slug: "modulo-bloqueado", unlocked: false) }
    let!(:locked_question) { create(:question, quiz_module: locked_module) }
    let!(:empty_module) { create(:quiz_module, slug: "modulo-vazio", unlocked: true) }

    it "redireciona para o início com alerta ao tentar jogar um módulo bloqueado" do
      get play_quiz_module_path(slug: locked_module.slug, locale: "pt-BR")
      expect(response).to redirect_to(root_path(locale: "pt-BR"))
      follow_redirect!
      expect(response.body).to include("Este módulo ainda está bloqueado.")
    end

    it "redireciona para o início com alerta em inglês ao tentar jogar um módulo bloqueado com locale en" do
      get play_quiz_module_path(slug: locked_module.slug, locale: "en")
      expect(response).to redirect_to(root_path(locale: "en"))
      follow_redirect!
      expect(response.body).to include("This module is currently locked.")
    end

    it "redireciona para o início com alerta ao tentar jogar um módulo sem questões" do
      get play_quiz_module_path(slug: empty_module.slug, locale: "pt-BR")
      expect(response).to redirect_to(root_path(locale: "pt-BR"))
      follow_redirect!
      expect(response.body).to include("Este módulo ainda não possui questões cadastradas.")
    end

    it "redireciona para o início ao tentar responder em módulo bloqueado" do
      post answer_quiz_module_path(slug: locked_module.slug, locale: "pt-BR"), params: { option_index: 0, question_id: 1 }
      expect(response).to redirect_to(root_path(locale: "pt-BR"))
    end

    it "redireciona para o início ao tentar ver resultado de módulo bloqueado" do
      get result_quiz_module_path(slug: locked_module.slug, locale: "pt-BR")
      expect(response).to redirect_to(root_path(locale: "pt-BR"))
    end
  end
end
