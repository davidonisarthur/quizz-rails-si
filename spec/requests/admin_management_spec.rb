require "rails_helper"

RSpec.describe "Administration", type: :request do
  let!(:admin) { create(:user, :admin, email: "admin-management@example.com", password: "password123") }
  let!(:student) { create(:user, email: "admin-student@example.com", password: "password123") }

  def sign_in(user)
    post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }
  end

  it "lists pending requests and lets an admin reject one exactly once" do
    request = create(:teacher_access_request, user: student)
    sign_in(admin)

    get admin_teacher_access_requests_path(locale: "pt-BR")
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(student.email)

    patch reject_admin_teacher_access_request_path(request, locale: "pt-BR")
    expect(request.reload).to be_rejected
    expect(request.reviewed_by).to eq(admin)
    expect(request.reviewed_at).to be_present

    patch reject_admin_teacher_access_request_path(request, locale: "pt-BR")
    expect(response).to have_http_status(:not_found)
  end

  it "issues invitation links and rejects invalid invitation email addresses" do
    sign_in(admin)

    get admin_teacher_invitations_path(locale: "pt-BR")
    expect(response).to have_http_status(:ok)

    expect {
      post admin_teacher_invitations_path(locale: "pt-BR"), params: { email: "teacher-invite@example.com" }
    }.to change(TeacherInvitation, :count).by(1)
    expect(flash[:invitation_url]).to include("invitation_token=")

    expect {
      post admin_teacher_invitations_path(locale: "pt-BR"), params: { email: "invalid-address" }
    }.not_to change(TeacherInvitation, :count)
    expect(response).to redirect_to(admin_teacher_invitations_path(locale: "pt-BR"))
    expect(flash[:alert]).to eq("Não foi possível criar o convite.")
  end

  it "does not expose administration to a student" do
    sign_in(student)

    get admin_teacher_invitations_path(locale: "pt-BR")
    expect(response).to have_http_status(:forbidden)
  end

  it "redirects an unauthenticated visitor to sign in" do
    get admin_teacher_invitations_path(locale: "pt-BR")

    expect(response).to redirect_to(new_session_path(locale: "pt-BR"))
    expect(flash[:alert]).to eq("Faça login para acessar a administração.")
  end
end
