# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri :self
    policy.object_src :none
    policy.frame_ancestors :self
    policy.form_action :self

    policy.script_src :self, "https://vlibras.gov.br"
    # The quiz progress bar uses a server-generated inline width style.
    policy.style_src :self, :unsafe_inline, "https://vlibras.gov.br"
    policy.img_src :self, :data, "https://vlibras.gov.br", "https://i.ytimg.com"
    policy.font_src :self, :data, "https://vlibras.gov.br"
    policy.connect_src :self, "https://vlibras.gov.br"
    policy.frame_src "https://www.youtube.com"
  end

  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
  config.content_security_policy_nonce_auto = true
end
