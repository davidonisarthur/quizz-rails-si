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
end
