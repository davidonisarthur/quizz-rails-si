require "rails_helper"

RSpec.describe "Classroom management", type: :request do
  let!(:teacher) { create(:user, :teacher, email: "teacher-classrooms@example.com", password: "password123") }
  let!(:other_teacher) { create(:user, :teacher, email: "other-classrooms@example.com", password: "password123") }
  let!(:student) { create(:user, email: "student-classrooms@example.com", password: "password123") }

  def sign_in(user)
    post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }
  end

  it "creates, lists, and deletes only the signed-in teacher's classrooms" do
    other_classroom = other_teacher.classrooms.create!(name: "Turma de outra pessoa")
    sign_in(teacher)

    expect {
      post teacher_classrooms_path(locale: "pt-BR"), params: { classroom: { name: "Turma A" } }
    }.to change(Classroom, :count).by(1)

    classroom = teacher.classrooms.find_by!(name: "Turma A")
    expect(response).to redirect_to(teacher_classroom_path(classroom, locale: "pt-BR"))

    get teacher_classrooms_path(locale: "pt-BR")
    expect(response.body).to include("Turma A")
    expect(response.body).not_to include(other_classroom.name)

    expect {
      delete teacher_classroom_path(classroom, locale: "pt-BR")
    }.to change(Classroom, :count).by(-1)

    expect(response).to redirect_to(teacher_classrooms_path(locale: "pt-BR"))
  end

  it "rejects invalid classrooms and hides classrooms belonging to another teacher" do
    other_classroom = other_teacher.classrooms.create!(name: "Turma privada")
    sign_in(teacher)

    expect {
      post teacher_classrooms_path(locale: "pt-BR"), params: { classroom: { name: "" } }
    }.not_to change(Classroom, :count)
    expect(response).to have_http_status(:unprocessable_entity)

    get teacher_classroom_path(other_classroom, locale: "pt-BR")
    expect(response).to have_http_status(:not_found)
  end

  it "enrolls a student by normalized email, prevents duplicates, and removes the enrollment" do
    classroom = teacher.classrooms.create!(name: "Turma de matrículas")
    sign_in(teacher)

    expect {
      post teacher_classroom_classroom_enrollments_path(classroom, locale: "pt-BR"), params: { email: "  #{student.email.upcase} " }
    }.to change(ClassroomEnrollment, :count).by(1)

    enrollment = classroom.classroom_enrollments.find_by!(user: student)
    expect(response).to redirect_to(teacher_classroom_path(classroom, locale: "pt-BR"))

    post teacher_classroom_classroom_enrollments_path(classroom, locale: "pt-BR"), params: { email: student.email }
    expect(response).to redirect_to(teacher_classroom_path(classroom, locale: "pt-BR"))
    expect(flash[:alert]).to eq("Este aluno já está na turma.")

    expect {
      delete teacher_classroom_classroom_enrollment_path(classroom, enrollment, locale: "pt-BR")
    }.to change(ClassroomEnrollment, :count).by(-1)
  end

  it "does not enroll teachers or expose another teacher's enrollment endpoint" do
    classroom = teacher.classrooms.create!(name: "Turma protegida")
    other_classroom = other_teacher.classrooms.create!(name: "Turma externa")
    sign_in(teacher)

    expect {
      post teacher_classroom_classroom_enrollments_path(classroom, locale: "pt-BR"), params: { email: other_teacher.email }
    }.not_to change(ClassroomEnrollment, :count)
    expect(flash[:alert]).to eq("Aluno não encontrado.")

    post teacher_classroom_classroom_enrollments_path(other_classroom, locale: "pt-BR"), params: { email: student.email }
    expect(response).to have_http_status(:not_found)
  end

  it "assigns a module to an owned classroom, prevents duplicates, and removes it" do
    classroom = teacher.classrooms.create!(name: "Turma com módulo")
    module_record = create(:quiz_module, created_by: teacher)
    sign_in(teacher)

    expect {
      post teacher_quiz_module_module_assignments_path(module_record, locale: "pt-BR"), params: { classroom_id: classroom.id }
    }.to change(ModuleAssignment, :count).by(1)

    assignment = module_record.module_assignments.find_by!(classroom: classroom)
    post teacher_quiz_module_module_assignments_path(module_record, locale: "pt-BR"), params: { classroom_id: classroom.id }
    expect(response).to redirect_to(teacher_quiz_module_path(module_record, locale: "pt-BR"))
    expect(flash[:alert]).to eq("A turma já possui este módulo.")

    expect {
      delete teacher_quiz_module_module_assignment_path(module_record, assignment, locale: "pt-BR")
    }.to change(ModuleAssignment, :count).by(-1)
  end

  it "does not assign a module to a classroom owned by another teacher" do
    module_record = create(:quiz_module, created_by: teacher)
    other_classroom = other_teacher.classrooms.create!(name: "Turma de outro professor")
    sign_in(teacher)

    expect {
      post teacher_quiz_module_module_assignments_path(module_record, locale: "pt-BR"), params: { classroom_id: other_classroom.id }
    }.not_to change(ModuleAssignment, :count)

    expect(response).to have_http_status(:not_found)
  end
end
