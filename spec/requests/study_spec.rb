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

  it "records started and completed progress for authenticated students" do
    user = create(:user, password: "password123")
    post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }

    expect {
      post study_progress_path("turing-machine", locale: "pt-BR", status: "started")
    }.to change(user.study_progresses, :count).by(1)

    progress = user.study_progresses.find_by!(study_slug: "turing-machine")
    expect(progress).not_to be_completed
    expect(response).to redirect_to(study_topic_path("turing-machine", locale: "pt-BR"))

    post study_progress_path("turing-machine", locale: "pt-BR", status: "completed")
    expect(progress.reload).to be_completed

    get study_path(locale: "pt-BR")
    expect(response.body).to include("Concluído")
  end

  it "requires authentication and does not track unpublished or unknown content" do
    draft_module = create(:study_module, published: false)

    post study_progress_path("turing-machine", locale: "pt-BR", status: "started")
    expect(response).to redirect_to(new_session_path(locale: "pt-BR"))

    user = create(:user, password: "password123")
    post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }
    post study_progress_path(draft_module.slug, locale: "pt-BR", status: "started")
    expect(response).to have_http_status(:not_found)

    post study_progress_path("unknown-topic", locale: "pt-BR", status: "started")
    expect(response).to have_http_status(:not_found)
  end

  it "offers an available linked quiz after a study module" do
    quiz_module = create(:quiz_module, created_by: create(:user, :teacher), unlocked: true, published: true, title_pt: "Quiz de lógica")
    create(:question, quiz_module: quiz_module, published: true)
    study_module = create(:study_module, published: true, created_by: quiz_module.created_by, quiz_module: quiz_module)

    get study_topic_path(study_module.slug, locale: "pt-BR")

    expect(response.body).to include("Próxima atividade")
    expect(response.body).to include("Quiz de lógica")
    expect(response.body).to include(play_quiz_module_path(quiz_module.slug, locale: "pt-BR"))
  end

  it "renders formatted sections from the rich-text editor" do
    study_module = build(:study_module, published: true, content_pt: "", content_en: "")
    study_module.rich_content_pt = "<h1>Uma seção importante</h1><div>Texto com <strong>destaque</strong>.</div>"
    study_module.rich_content_en = "<h1>An important section</h1><div>Text with <strong>emphasis</strong>.</div>"
    study_module.save!

    get study_topic_path(study_module.slug, locale: "pt-BR")

    expect(response.body).to include("Uma seção importante")
    expect(response.body).to include("Texto com <strong>destaque</strong>")
  end
end
