require "rails_helper"

RSpec.describe "Teacher study modules", type: :request do
  let!(:teacher) { create(:user, :teacher, email: "teacher-study@example.com", password: "password123") }
  let!(:student) { create(:user, email: "student-study@example.com", password: "password123") }

  def sign_in(user)
    post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }
  end

  def study_module_params(position: 10)
    {
      title_pt: "Lógica para iniciantes", title_en: "Logic for beginners",
      summary_pt: "Resumo em português", summary_en: "Summary in English",
      content_pt: "Texto completo em português.", content_en: "Full English text.",
      libras_content_pt: "Texto curto em português.", libras_content_en: "Short English text.",
      slug: "logica-iniciantes", position: position, published: "1", video_url: "https://example.com/video"
    }
  end

  it "allows a teacher to create, update, and remove their study content" do
    sign_in(teacher)

    expect {
      post teacher_study_modules_path(locale: "pt-BR"), params: { study_module: study_module_params.merge(created_by_id: student.id) }
    }.to change(StudyModule, :count).by(1)

    study_module = StudyModule.last
    expect(study_module.created_by).to eq(teacher)
    expect(study_module).to be_published

    patch teacher_study_module_path(study_module, locale: "pt-BR"), params: { study_module: study_module_params.merge(title_pt: "Lógica atualizada") }
    expect(response).to redirect_to(teacher_study_module_path(study_module, locale: "pt-BR"))
    expect(study_module.reload.title_pt).to eq("Lógica atualizada")

    expect {
      delete teacher_study_module_path(study_module, locale: "pt-BR")
    }.to change(StudyModule, :count).by(-1)
  end

  it "persists the fallback text columns when the editor sends rich content" do
    sign_in(teacher)
    rich_content = study_module_params(position: 13).except(:content_pt, :content_en).merge(
      slug: "conteudo-rico",
      rich_content_pt: "<h1>Algoritmos</h1><div>Texto em português.</div>",
      rich_content_en: "<h1>Algorithms</h1><div>English text.</div>"
    )

    expect {
      post teacher_study_modules_path(locale: "pt-BR"), params: { study_module: rich_content }
    }.to change(StudyModule, :count).by(1)

    created_module = StudyModule.last
    expect(created_module.content_pt).to include("Algoritmos")
    expect(created_module.content_en).to include("Algorithms")
    expect(created_module.rich_content_pt.to_plain_text).to include("Texto em português")
  end

  it "does not allow students or other teachers to manage the content" do
    study_module = create(:study_module, created_by: teacher)
    sign_in(student)
    get teacher_study_modules_path(locale: "pt-BR")
    expect(response).to have_http_status(:forbidden)

    delete session_path(locale: "pt-BR")
    other_teacher = create(:user, :teacher, email: "other-study@example.com", password: "password123")
    sign_in(other_teacher)
    get teacher_study_module_path(study_module, locale: "pt-BR")
    expect(response).to have_http_status(:not_found)
  end

  it "allows a teacher to assign classroom-only study content to their own classroom" do
    classroom = teacher.classrooms.create!(name: "Turma privada")
    study_module = create(:study_module, created_by: teacher, audience: "classroom_audience")
    sign_in(teacher)

    expect {
      post teacher_study_module_study_module_assignments_path(study_module, locale: "pt-BR"), params: { classroom_id: classroom.id }
    }.to change(StudyModuleAssignment, :count).by(1)

    post teacher_study_module_study_module_assignments_path(study_module, locale: "pt-BR"), params: { classroom_id: classroom.id }
    expect(flash[:alert]).to eq("A turma já possui este conteúdo de estudo.")
  end

  it "does not let a teacher manage platform study content" do
    platform_study = create(:study_module, created_by: teacher, platform_default: true)
    sign_in(teacher)

    get teacher_study_module_path(platform_study, locale: "pt-BR")

    expect(response).to have_http_status(:not_found)
  end

  it "protects image upload URLs from guests and students" do
    post "/rails/active_storage/direct_uploads"
    expect(response).to have_http_status(:forbidden)

    sign_in(student)
    post "/rails/active_storage/direct_uploads"
    expect(response).to have_http_status(:forbidden)
  end

  it "rerenders the form when content is incomplete" do
    sign_in(teacher)

    post teacher_study_modules_path(locale: "pt-BR"), params: { study_module: study_module_params.merge(content_en: "") }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "renders rich-text editors with image upload support" do
    sign_in(teacher)

    get new_teacher_study_module_path(locale: "pt-BR")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("trix-editor")
    expect(response.body).to include("direct-upload-url")
    expect(response.body).to include('href="/assets/trix-')
  end

  it "allows only the teacher's own quizzes to be linked" do
    own_quiz = create(:quiz_module, created_by: teacher)
    other_quiz = create(:quiz_module, created_by: create(:user, :teacher))
    sign_in(teacher)

    post teacher_study_modules_path(locale: "pt-BR"), params: { study_module: study_module_params(position: 11).merge(slug: "conteudo-com-quiz", quiz_module_id: own_quiz.id) }
    expect(StudyModule.last.quiz_module).to eq(own_quiz)

    post teacher_study_modules_path(locale: "pt-BR"), params: { study_module: study_module_params(position: 12).merge(slug: "conteudo-invalido", quiz_module_id: other_quiz.id) }
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
