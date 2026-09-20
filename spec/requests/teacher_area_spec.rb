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

  it "shows the teacher navigation only to teachers" do
    sign_in(student)
    get root_path(locale: "pt-BR")
    expect(response.body).not_to include("Professor")

    delete session_path(locale: "pt-BR")
    sign_in(teacher)
    get root_path(locale: "pt-BR")
    expect(response.body).to include("Professor")
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
    expect(response).to have_http_status(:not_found)
  end
end
