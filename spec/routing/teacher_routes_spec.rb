require "rails_helper"

RSpec.describe "Teacher routes", type: :routing do
  it "routes classroom and quiz deletion through their protected teacher controllers" do
    expect(delete: "/pt-BR/teacher/classrooms/12").to route_to(
      controller: "teacher/classrooms", action: "destroy", locale: "pt-BR", id: "12"
    )
    expect(delete: "/pt-BR/teacher/quiz_modules/8").to route_to(
      controller: "teacher/quiz_modules", action: "destroy", locale: "pt-BR", id: "8"
    )
  end

  it "routes study assignment removal as a nested teacher action" do
    expect(delete: "/pt-BR/teacher/study_modules/6/study_module_assignments/4").to route_to(
      controller: "teacher/study_module_assignments", action: "destroy",
      locale: "pt-BR", study_module_id: "6", id: "4"
    )
  end

  it "does not expose destructive teacher routes with GET" do
    expect(get: "/pt-BR/teacher/classrooms/12").to route_to(
      controller: "teacher/classrooms", action: "show", locale: "pt-BR", id: "12"
    )
    expect(get: "/pt-BR/teacher/quiz_modules/8").to route_to(
      controller: "teacher/quiz_modules", action: "show", locale: "pt-BR", id: "8"
    )
  end
end
