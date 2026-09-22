require "rails_helper"

RSpec.describe "Role journeys", type: :system do
  self.use_transactional_tests = false

  let(:student_email) { "student-e2e@example.com" }
  let(:teacher_email) { "teacher-e2e@example.com" }

  after do
    QuizModule.where(created_by_id: User.where(email: teacher_email).select(:id)).destroy_all
    StudyModule.where(created_by_id: User.where(email: teacher_email).select(:id)).destroy_all
    User.where(email: [ student_email, teacher_email ]).destroy_all
  end

  it "lets a new student register, review their profile, and start studying" do
    visit new_user_path(locale: "pt-BR")

    fill_in "Nome completo", with: "Estudante E2E"
    fill_in "Email", with: student_email
    fill_in "Senha", with: "password123"
    fill_in "Confirme a senha", with: "password123"
    click_button "Criar Conta"

    expect(page).to have_current_path(root_path(locale: "pt-BR"), ignore_query: true)
    find("summary", text: "Minha conta").click
    click_link "Perfil"

    expect(page).to have_current_path(profile_path(locale: "pt-BR"), ignore_query: true)
    expect(page).to have_content("Estudante E2E")
    expect(page).to have_content("Continue aprendendo além dos quizzes")

    click_link "Explorar conteúdos de estudo"
    expect(page).to have_current_path(study_path(locale: "pt-BR"), ignore_query: true)
    expect(page).to have_content("Conteúdos para estudar")
  end

  it "lets a teacher sign in and manage authored content from the dashboard" do
    create(:user, :teacher, email: teacher_email, password: "password123")

    visit new_session_path(locale: "pt-BR")
    fill_in "Email", with: teacher_email
    fill_in "Senha", with: "password123"
    click_button "Entrar"

    expect(page).to have_current_path(teacher_root_path(locale: "pt-BR"), ignore_query: true)
    expect(page).to have_content("Painel do professor")
    expect(page).not_to have_content("Meu progresso")

    click_link "Criar quiz", match: :first
    expect(page).to have_current_path(new_teacher_quiz_module_path(locale: "pt-BR"), ignore_query: true)
    expect(page).to have_content("Como criar um quiz")
  end
end
