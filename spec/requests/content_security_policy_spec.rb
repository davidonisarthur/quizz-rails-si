require 'rails_helper'

RSpec.describe "Content Security Policy", type: :request do
  it "emits a restrictive policy while allowing the approved accessibility providers" do
    get root_path(locale: "pt-BR")

    policy = response.headers.fetch("Content-Security-Policy")
    expect(policy).to include("default-src 'self'")
    expect(policy).to include("object-src 'none'")
    expect(policy).to include("script-src 'self' https://vlibras.gov.br 'nonce-")
    expect(policy).to include("frame-src https://www.youtube.com")
    expect(response.body).to match(/<script nonce="[^"]+">/)
  end
end
