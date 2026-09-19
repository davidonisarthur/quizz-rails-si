require 'rails_helper'

RSpec.describe "Module progression", type: :request do
  let!(:first_module) { create(:quiz_module, position: 1, unlocked: true) }
  let!(:second_module) { create(:quiz_module, position: 2, unlocked: false) }
  let!(:question) { create(:question, quiz_module: second_module) }

  it "keeps the next module locked until the preceding module is completed" do
    get play_quiz_module_path(slug: second_module.slug, locale: "pt-BR")

    expect(response).to redirect_to(root_path(locale: "pt-BR"))
  end

  it "allows a learner who completed the preceding module to start the next one" do
    user = create(:user)
    create(:quiz_attempt, user: user, quiz_module: first_module, score: 0)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    get play_quiz_module_path(slug: second_module.slug, locale: "pt-BR")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(question.body_pt)
  end
end
