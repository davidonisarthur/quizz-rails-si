require "rails_helper"

RSpec.describe "Teacher area", type: :request do
  let!(:teacher) { create(:user, :teacher, email: "teacher@example.com", password: "password123") }
  let!(:student) { create(:user, email: "student@example.com", password: "password123") }

  def sign_in(user)
    post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }
  end

  it "redirects unauthenticated visitors to sign in" do
    get teacher_root_path(locale: "pt-BR")

    expect(response).to redirect_to(new_session_path(locale: "pt-BR"))
  end

  it "returns forbidden for an authenticated student, even with the direct URL" do
    sign_in(student)
    get teacher_root_path(locale: "pt-BR")

    expect(response).to have_http_status(:forbidden)
  end

  it "keeps the student profile for students and sends teachers to their dashboard" do
    sign_in(student)
    get root_path(locale: "pt-BR")
    expect(response.body).to include("Perfil")
    expect(response.body).not_to include("Meu painel")

    delete session_path(locale: "pt-BR")
    sign_in(teacher)
    get root_path(locale: "pt-BR")
    expect(response).to redirect_to(teacher_root_path(locale: "pt-BR"))

    follow_redirect!
    expect(response.body).to include("Meu painel")
    expect(response.body).not_to include('href="/pt-BR/profile"')

    get profile_path(locale: "pt-BR")
    expect(response).to redirect_to(teacher_root_path(locale: "pt-BR"))
  end

  it "renders the teacher dashboard and the module index" do
    module_record = create(:quiz_module, created_by: teacher, title_pt: "Módulo do painel")
    sign_in(teacher)

    get teacher_root_path(locale: "pt-BR")
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(module_record.title_pt)

    get teacher_quiz_modules_path(locale: "pt-BR")
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(module_record.title_pt)
  end

  it "summarizes authored content, classes, and enrolled students on the teacher dashboard" do
    teacher.classrooms.create!(name: "Turma do painel").classroom_enrollments.create!(user: student)
    create(:quiz_module, created_by: teacher, published: false)
    create(:study_module, created_by: teacher, published: true)
    sign_in(teacher)

    get teacher_root_path(locale: "pt-BR")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Turmas")
    expect(response.body).to include("Alunos")
    expect(response.body).to include("Conteúdos publicados")
    expect(response.body).to include("Rascunhos")
  end

  it "prevents teachers from recording quiz attempts through learner routes" do
    module_record = create(:quiz_module, created_by: teacher)
    create(:question, quiz_module: module_record)
    sign_in(teacher)

    get play_quiz_module_path(module_record.slug, locale: "pt-BR")
    expect(response).to redirect_to(teacher_root_path(locale: "pt-BR"))

    expect {
      post answer_quiz_module_path(module_record.slug, locale: "pt-BR", question_id: 1, option_index: 0)
    }.not_to change(QuizAttempt, :count)

    expect(response).to redirect_to(teacher_root_path(locale: "pt-BR"))
    expect(flash[:alert]).to eq("Professores revisam quizzes pela pré-visualização no painel do professor.")

    get quiz_modules_path(locale: "pt-BR")
    expect(response).to redirect_to(teacher_root_path(locale: "pt-BR"))
  end

  it "renders module forms, updates a draft, and deletes the module" do
    module_record = create(:quiz_module, created_by: teacher, published: false, title_pt: "Rascunho inicial")
    sign_in(teacher)

    get new_teacher_quiz_module_path(locale: "pt-BR")
    expect(response).to have_http_status(:ok)

    get teacher_quiz_module_path(module_record, locale: "pt-BR")
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Excluir quiz")
    expect(response.body).to include("_method\" value=\"delete")
    get edit_teacher_quiz_module_path(module_record, locale: "pt-BR")
    expect(response).to have_http_status(:ok)

    patch teacher_quiz_module_path(module_record, locale: "pt-BR"), params: {
      quiz_module: { title_pt: "Rascunho atualizado", title_en: "Updated draft", slug: module_record.slug, position: module_record.position, unlocked: "0", published: "0", audience: "public_audience" }
    }
    expect(response).to redirect_to(teacher_quiz_module_path(module_record, locale: "pt-BR"))
    expect(module_record.reload.title_pt).to eq("Rascunho atualizado")

    expect {
      delete teacher_quiz_module_path(module_record, locale: "pt-BR")
    }.to change(QuizModule, :count).by(-1)
  end

  it "keeps a quiz and reports an error when its deletion is blocked" do
    module_record = create(:quiz_module, created_by: teacher, published: false)
    sign_in(teacher)
    allow_any_instance_of(QuizModule).to receive(:destroy) do |record|
      record.errors.add(:base, "O quiz não pode ser excluído agora")
      false
    end

    expect {
      delete teacher_quiz_module_path(module_record, locale: "pt-BR")
    }.not_to change(QuizModule, :count)

    expect(response).to redirect_to(teacher_quiz_module_path(module_record, locale: "pt-BR"))
    expect(flash[:alert]).to eq("O quiz não pode ser excluído agora")
  end

  it "rejects invalid module updates and publishing without a published question" do
    module_record = create(:quiz_module, created_by: teacher, published: false)
    sign_in(teacher)

    patch teacher_quiz_module_path(module_record, locale: "pt-BR"), params: {
      quiz_module: { title_pt: "", title_en: module_record.title_en, slug: module_record.slug, position: module_record.position, unlocked: "0", published: "0", audience: "public_audience" }
    }
    expect(response).to have_http_status(:unprocessable_entity)

    patch teacher_quiz_module_path(module_record, locale: "pt-BR"), params: {
      quiz_module: { title_pt: module_record.title_pt, title_en: module_record.title_en, slug: module_record.slug, position: module_record.position, unlocked: "0", published: "1", audience: "public_audience" }
    }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(module_record.reload).not_to be_published
  end

  it "assigns new modules to the signed-in teacher and ignores ownership parameters" do
    sign_in(teacher)

    expect {
      post teacher_quiz_modules_path(locale: "pt-BR"), params: {
        quiz_module: {
          title_pt: "Módulo da professora", title_en: "Teacher module", slug: "modulo-professora",
          position: 10, unlocked: "0", published: "0", created_by_id: student.id
        }
      }
    }.to change(QuizModule, :count).by(1)

    module_record = QuizModule.last
    expect(module_record.created_by).to eq(teacher)
    expect(module_record).not_to be_published
  end

  it "does not allow one teacher to access another teacher's module" do
    module_record = create(:quiz_module, created_by: teacher)
    other_teacher = create(:user, :teacher, email: "other-teacher@example.com", password: "password123")
    sign_in(other_teacher)

    get teacher_quiz_module_path(module_record, locale: "pt-BR")

    expect(response).to have_http_status(:not_found)
  end

  it "duplicates a question with its content as a new draft" do
    module_record = create(:quiz_module, created_by: teacher)
    question = create(:question, quiz_module: module_record, position: 1, published: true)
    4.times { create(:option, question: question) }
    create(:feedback, question: question, kind: "correct")
    create(:feedback, question: question, kind: "incorrect")
    sign_in(teacher)

    expect {
      post duplicate_teacher_quiz_module_question_path(module_record, question, locale: "pt-BR")
    }.to change(Question, :count).by(1)
      .and change(Option, :count).by(4)
      .and change(Feedback, :count).by(2)

    copy = Question.order(:id).last
    expect(copy).not_to be_published
    expect(copy.position).to eq(2)
    expect(copy.body_pt).to eq(question.body_pt)
    expect(response).to redirect_to(edit_teacher_quiz_module_question_path(module_record, copy, locale: "pt-BR"))
  end

  it "moves a question without exposing a cross-module ordering endpoint" do
    module_record = create(:quiz_module, created_by: teacher)
    first_question = create(:question, quiz_module: module_record, position: 1)
    second_question = create(:question, quiz_module: module_record, position: 2)
    sign_in(teacher)

    patch move_teacher_quiz_module_question_path(module_record, second_question, locale: "pt-BR"), params: { direction: "up" }

    expect(response).to redirect_to(teacher_quiz_module_path(module_record, locale: "pt-BR"))
    expect(first_question.reload.position).to eq(2)
    expect(second_question.reload.position).to eq(1)
  end

  it "renders question forms, updates a draft with complete details, and deletes it" do
    module_record = create(:quiz_module, created_by: teacher)
    question = create(:question, quiz_module: module_record, published: false)
    sign_in(teacher)

    get new_teacher_quiz_module_question_path(module_record, locale: "pt-BR")
    expect(response).to have_http_status(:ok)
    get edit_teacher_quiz_module_question_path(module_record, question, locale: "pt-BR")
    expect(response).to have_http_status(:ok)

    patch teacher_quiz_module_question_path(module_record, question, locale: "pt-BR"), params: {
      question: {
        body_pt: "Questão atualizada", body_en: "Updated question", context_pt: "Contexto", context_en: "Context", correct_index: "0", published: "0",
        options_attributes: 4.times.map { |index| { text_pt: "Alternativa #{index}", text_en: "Option #{index}" } },
        feedbacks_attributes: [ { kind: "correct", body_pt: "Certo", body_en: "Correct" }, { kind: "incorrect", body_pt: "Errado", body_en: "Incorrect" } ]
      }
    }
    expect(response).to redirect_to(teacher_quiz_module_path(module_record, locale: "pt-BR"))
    expect(question.reload.body_pt).to eq("Questão atualizada")

    expect {
      delete teacher_quiz_module_question_path(module_record, question, locale: "pt-BR")
    }.to change(Question, :count).by(-1)
  end

  it "rerenders the question form when an otherwise draft update fails validation" do
    module_record = create(:quiz_module, created_by: teacher)
    question = create(:question, quiz_module: module_record, published: false)
    sign_in(teacher)

    patch teacher_quiz_module_question_path(module_record, question, locale: "pt-BR"), params: {
      question: { body_pt: "Questão inválida", correct_index: "0", published: "0", libras_video_url: "https://youtu.be/dQw4w9WgXcQ" }
    }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "keeps a question in place when it has no neighbour in the requested direction" do
    module_record = create(:quiz_module, created_by: teacher)
    question = create(:question, quiz_module: module_record, position: 1)
    sign_in(teacher)

    patch move_teacher_quiz_module_question_path(module_record, question, locale: "pt-BR"), params: { direction: "down" }

    expect(response).to redirect_to(teacher_quiz_module_path(module_record, locale: "pt-BR"))
    expect(question.reload.position).to eq(1)
    expect(flash[:notice]).to be_nil
  end

  it "keeps module previews private while showing drafts to their teacher" do
    module_record = create(:quiz_module, created_by: teacher)
    create(:question, quiz_module: module_record, published: false, body_pt: "Rascunho visível apenas aqui")
    sign_in(teacher)

    get preview_teacher_quiz_module_path(module_record, locale: "pt-BR")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Rascunho visível apenas aqui")

    delete session_path(locale: "pt-BR")
    sign_in(student)
    get preview_teacher_quiz_module_path(module_record, locale: "pt-BR")

    expect(response).to have_http_status(:forbidden)
  end

  it "shows reports only for modules owned by the signed-in teacher" do
    module_record = create(:quiz_module, created_by: teacher)
    question = create(:question, quiz_module: module_record, position: 1, body_pt: "Questão analisada")
    attempt = create(:quiz_attempt, user: student, quiz_module: module_record, score: 1)
    create(:quiz_response, quiz_attempt: attempt, question: question, selected_index: 1, correct: true)
    sign_in(teacher)

    get report_teacher_quiz_module_path(module_record, locale: "pt-BR")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Questão analisada")
    expect(response.body).to include(student.name)

    other_teacher = create(:user, :teacher, email: "reports-other@example.com", password: "password123")
    delete session_path(locale: "pt-BR")
    sign_in(other_teacher)
    get report_teacher_quiz_module_path(module_record, locale: "pt-BR")

    expect(response).to have_http_status(:not_found)
  end

  it "does not publish an incomplete question" do
    module_record = create(:quiz_module, created_by: teacher)
    sign_in(teacher)

    expect {
      post teacher_quiz_module_questions_path(module_record, locale: "pt-BR"), params: {
        question: { body_pt: "Questão incompleta", correct_index: 0, published: "1" }
      }
    }.not_to change(Question, :count)

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "does not expose draft modules through public quiz routes" do
    module_record = create(:quiz_module, created_by: teacher, published: false, title_pt: "Rascunho privado", slug: "rascunho-privado")
    create(:question, quiz_module: module_record, published: true)

    get root_path(locale: "pt-BR")
    expect(response.body).not_to include("Rascunho privado")

    get play_quiz_module_path(module_record.slug, locale: "pt-BR")
    expect(response).to redirect_to(root_path(locale: "pt-BR"))
    expect(flash[:alert]).to eq("Este módulo não está disponível para jogar.")
  end
end
