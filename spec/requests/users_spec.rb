require "rails_helper"

RSpec.describe "Users", type: :request do
  it "rerenders registration when user validation fails" do
    expect {
      post users_path(locale: "pt-BR"), params: {
        user: { name: "", email: "invalid-user@example.com", password: "password123", password_confirmation: "password123" }
      }
    }.not_to change(User, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Criar Conta")
  end

  it "shows zero learner progress when no quiz modules are available" do
    user = create(:user, email: "empty-profile@example.com", password: "password123")
    post session_path(locale: "pt-BR"), params: { email: user.email, password: "password123" }

    get profile_path(locale: "pt-BR")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("0 de 0 módulos concluídos")
  end
end
