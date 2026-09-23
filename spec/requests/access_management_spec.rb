require "rails_helper"

RSpec.describe "Access management", type: :request do
  let!(:admin) { create(:user, :admin, email: "admin@example.com", password: "password123") }
  let!(:teacher) { create(:user, :teacher, email: "teacher@example.com", password: "password123") }
  let!(:student) { create(:user, name: "Aluno da Turma", email: "student@example.com", password: "password123") }

  def sign_in(user)
    post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }
  end

  it "lets a student request teacher access but prevents self-promotion" do
    sign_in(student)

    expect {
      post teacher_access_requests_path(locale: "pt-BR")
    }.to change(TeacherAccessRequest, :count).by(1)

    expect(student.reload).to be_student
    post teacher_access_requests_path(locale: "pt-BR")
    expect(response).to redirect_to(profile_path(locale: "pt-BR"))
    expect(TeacherAccessRequest.count).to eq(1)
  end

  it "does not let an existing teacher create an access request" do
    sign_in(teacher)

    expect {
      post teacher_access_requests_path(locale: "pt-BR")
    }.not_to change(TeacherAccessRequest, :count)

    expect(response).to redirect_to(profile_path(locale: "pt-BR"))
    expect(flash[:alert]).to eq("Sua conta já possui acesso docente.")
  end

  it "requires an admin to approve teacher requests" do
    request = create(:teacher_access_request, user: student)
    sign_in(teacher)
    patch approve_admin_teacher_access_request_path(request, locale: "pt-BR")
    expect(response).to have_http_status(:forbidden)

    delete session_path(locale: "pt-BR")
    sign_in(admin)
    patch approve_admin_teacher_access_request_path(request, locale: "pt-BR")

    expect(student.reload).to be_teacher
    expect(request.reload).to be_approved
    expect(request.reviewed_by).to eq(admin)
  end

  it "issues invitations with expiring, single-use tokens" do
    invitation, token = TeacherInvitation.issue!(email: "invitee@example.com", invited_by: admin)
    expect(TeacherInvitation.find_valid(token)).to eq(invitation)

    invitation.update!(expires_at: 1.minute.ago)
    expect(TeacherInvitation.find_valid(token)).to be_nil

    fresh_invitation, fresh_token = TeacherInvitation.issue!(email: "invitee@example.com", invited_by: admin)
    post users_path(locale: "pt-BR"), params: {
      teacher_invitation_token: fresh_token,
      user: { name: "Invitee", email: "invitee@example.com", password: "password123", password_confirmation: "password123" }
    }

    expect(User.find_by(email: "invitee@example.com")).to be_teacher
    expect(fresh_invitation.reload.accepted_at).to be_present
    expect(TeacherInvitation.find_valid(fresh_token)).to be_nil
  end

  it "does not apply an invitation to a different email address" do
    _, token = TeacherInvitation.issue!(email: "allowed@example.com", invited_by: admin)

    expect {
      post users_path(locale: "pt-BR"), params: {
        teacher_invitation_token: token,
        user: { name: "Wrong", email: "wrong@example.com", password: "password123", password_confirmation: "password123" }
      }
    }.not_to change(User, :count)

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "restricts classroom modules to enrolled students and filters reports by classroom" do
    module_record = create(:quiz_module, created_by: teacher, audience: "classroom_audience", unlocked: true)
    question = create(:question, quiz_module: module_record, position: 1)
    classroom = teacher.classrooms.create!(name: "Turma A")
    classroom.classroom_enrollments.create!(user: student)
    module_record.module_assignments.create!(classroom: classroom)
    outside_student = create(:user, name: "Aluno Externo", email: "outside@example.com", password: "password123")
    included_attempt = create(:quiz_attempt, user: student, quiz_module: module_record, score: 1)
    excluded_attempt = create(:quiz_attempt, user: outside_student, quiz_module: module_record, score: 0)
    create(:quiz_response, quiz_attempt: included_attempt, question: question, correct: true)
    create(:quiz_response, quiz_attempt: excluded_attempt, question: question, correct: false)

    sign_in(outside_student)
    get play_quiz_module_path(module_record.slug, locale: "pt-BR")
    expect(response).to redirect_to(root_path(locale: "pt-BR"))

    delete session_path(locale: "pt-BR")
    sign_in(student)
    get play_quiz_module_path(module_record.slug, locale: "pt-BR")
    expect(response).to have_http_status(:ok)

    delete session_path(locale: "pt-BR")
    sign_in(teacher)
    get report_teacher_quiz_module_path(module_record, locale: "pt-BR", classroom_id: classroom.id)
    expect(response.body).to include(student.name)
    expect(response.body).not_to include(outside_student.name)
    expect(response.body).to include("1 respostas")
    expect(response.body).to include("100% de acerto")
  end

  it "does not fall back to the global report for a classroom the teacher does not own" do
    module_record = create(:quiz_module, created_by: teacher, unlocked: true)
    other_teacher = create(:user, :teacher, email: "other-teacher@example.com", password: "password123")
    other_classroom = other_teacher.classrooms.create!(name: "Turma de outro professor")

    sign_in(teacher)
    get report_teacher_quiz_module_path(module_record, locale: "pt-BR", classroom_id: other_classroom.id)

    expect(response).to have_http_status(:not_found)
  end
end
