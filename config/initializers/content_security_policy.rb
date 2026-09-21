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

    # VLibras v7 loads its application module from jsDelivr after the approved bootstrap script.
    policy.script_src :self, "https://vlibras.gov.br", "https://cdn.jsdelivr.net"
    # The quiz progress bar uses a server-generated inline width style.
    policy.style_src :self, :unsafe_inline, "https://vlibras.gov.br", "https://cdn.jsdelivr.net"
    policy.img_src :self, :data, "https://vlibras.gov.br", "https://cdn.jsdelivr.net", "https://i.ytimg.com"
    policy.font_src :self, :data, "https://vlibras.gov.br", "https://cdn.jsdelivr.net"
    policy.connect_src :self, "https://vlibras.gov.br", "https://traducao2.vlibras.gov.br", "https://dicionario2.vlibras.gov.br", "https://repositorio.vlibras.gov.br", "https://cdn.jsdelivr.net"
    policy.worker_src :self, :blob, "https://cdn.jsdelivr.net"
    policy.frame_src "https://www.youtube.com", "https://vlibras.gov.br"
  end

  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
  config.content_security_policy_nonce_auto = true
end
