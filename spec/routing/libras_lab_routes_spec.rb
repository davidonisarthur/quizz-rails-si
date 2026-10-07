require "rails_helper"

RSpec.describe "LIBRAS laboratory routes", type: :routing do
  it "routes the laboratory page" do
    expect(get: "/pt-BR/libras-lab").to route_to(
      controller: "libras_lab", action: "show", locale: "pt-BR"
    )
  end
end
