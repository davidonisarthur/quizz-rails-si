require 'rails_helper'

RSpec.describe "VLibras Layout Integration", type: :request do
  describe "GET /:locale" do
    it "includes VLibras script in head and permanent container in body" do
      get root_path(locale: "pt-BR")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('src="https://vlibras.gov.br/app/vlibras-plugin.js"')
      expect(response.body).to include('id="vlibras-widget-container"')
      expect(response.body).to include('data-turbo-permanent')
      expect(response.body).to include('data-controller="vlibras"')
      expect(response.body).to include('vw class="enabled"')
    end
  end
end
