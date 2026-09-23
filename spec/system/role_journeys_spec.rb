require "rails_helper"

RSpec.describe "Role journeys", type: :system do
  self.use_transactional_tests = false

  let(:student_email) { "student-e2e@example.com" }
  let(:teacher_email) { "teacher-e2e@example.com" }
  let(:enrolled_student_email) { "enrolled-student-e2e@example.com" }
  let(:outside_student_email) { "outside-student-e2e@example.com" }

  after do
    e2e_users = User.where(email: e2e_emails)
    QuizModule.where(created_by_id: e2e_users.select(:id)).destroy_all
    StudyModule.where(created_by_id: e2e_users.select(:id)).destroy_all
    e2e_users.find_each(&:destroy!)
  end

  def e2e_emails
    [ student_email, teacher_email, enrolled_student_email, outside_student_email ]
  end

  def sign_in_through_browser(email)
    visit new_session_path(locale: "pt-BR")
    fill_in "Email", with: email
    fill_in "Senha", with: "password123"
    click_button "Entrar"
    expect(page).to have_content("Minha conta")
  end

  def sign_out_through_browser
    find("summary", text: "Minha conta").click
    click_button "Sair"
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

    sign_in_through_browser(teacher_email)

    expect(page).to have_current_path(teacher_root_path(locale: "pt-BR"), ignore_query: true)
    expect(page).to have_content("Painel do professor")
    expect(page).not_to have_content("Meu progresso")

    click_link "Criar quiz", match: :first
    expect(page).to have_current_path(new_teacher_quiz_module_path(locale: "pt-BR"), ignore_query: true)
    expect(page).to have_content("Como criar um quiz")
  end

  it "lets a student complete a quiz and persist the result through the browser" do
    teacher = create(:user, :teacher, email: teacher_email, password: "password123")
    student = create(:user, email: student_email, password: "password123")
    quiz_module = create(:quiz_module, created_by: teacher, title_pt: "Quiz E2E público", slug: "quiz-e2e-publico", position: 301)
    question = create(:question, quiz_module: quiz_module, body_pt: "Qual resposta está correta?", correct_index: 1)
    create(:option, question: question, text_pt: "Resposta incorreta", text_en: "Wrong answer")
    create(:option, question: question, text_pt: "Resposta correta", text_en: "Correct answer")
    create(:option, question: question, text_pt: "Outra resposta", text_en: "Another answer")
    create(:option, question: question, text_pt: "Última resposta", text_en: "Last answer")
    create(:feedback, question: question, kind: "correct", body_pt: "Muito bem!", body_en: "Well done!")
    create(:feedback, question: question, kind: "incorrect", body_pt: "Tente outra vez.", body_en: "Try again.")

    sign_in_through_browser(student.email)
    visit root_path(locale: "pt-BR")
    within("article", text: "Quiz E2E público") { click_link "Jogar" }
    click_button "Resposta correta"

    expect(page).to have_content("Correto!")
    expect(page).to have_content("Muito bem!")

    click_link "Ver resultado"
    expect(page).to have_content("Quiz Finalizado!")
    expect(page).to have_content("1 / 1")
    expect(student.quiz_attempts.find_by(quiz_module: quiz_module)).to have_attributes(score: 1)
  end

  it "lets a teacher create a classroom and a classroom-only quiz through the interface" do
    create(:user, :teacher, email: teacher_email, password: "password123")

    sign_in_through_browser(teacher_email)
    click_link "Gerenciar turmas"
    fill_in "Nome da turma", with: "Turma E2E"
    click_button "Criar turma"

    expect(page).to have_current_path(/\/teacher\/classrooms\/\d+/)
    expect(page).to have_content("Turma E2E")

    click_link "Meu painel"
    click_link "Criar quiz", match: :first
    fill_in "Título em português", with: "Quiz da Turma E2E"
    fill_in "Título em inglês", with: "E2E Class Quiz"
    fill_in "Identificador da URL", with: "quiz-turma-e2e"
    fill_in "Ordem do módulo", with: 302
    select "Somente turmas atribuídas", from: "Visibilidade"
    click_button "Salvar"

    expect(page).to have_content("Quiz da Turma E2E")
    expect(page).to have_content("Turmas com acesso")
    select "Turma E2E", from: "classroom_id"
    click_button "Atribuir"

    expect(page).to have_content("Módulo atribuído à turma.")
    expect(page).to have_content("Turma E2E")
  end

  it "shows a classroom-only quiz only to the student enrolled in that classroom" do
    teacher = create(:user, :teacher, email: teacher_email, password: "password123")
    enrolled_student = create(:user, email: enrolled_student_email, password: "password123")
    outside_student = create(:user, email: outside_student_email, password: "password123")
    classroom = teacher.classrooms.create!(name: "Turma restrita E2E")
    classroom.classroom_enrollments.create!(user: enrolled_student)
    quiz_module = create(:quiz_module, created_by: teacher, title_pt: "Quiz restrito E2E", slug: "quiz-restrito-e2e", position: 303, audience: "classroom_audience")
    create(:question, quiz_module: quiz_module)
    ModuleAssignment.create!(classroom: classroom, quiz_module: quiz_module)

    sign_in_through_browser(outside_student.email)
    visit root_path(locale: "pt-BR")
    expect(page).not_to have_content("Quiz restrito E2E")

    sign_out_through_browser
    sign_in_through_browser(enrolled_student.email)
    visit root_path(locale: "pt-BR")
    expect(page).to have_content("Quiz restrito E2E")
  end
end
