require "rails_helper"

RSpec.describe ClassroomEnrollment, type: :model do
  it "accepts students and rejects teachers as classroom members" do
    teacher = create(:user, :teacher)
    classroom = teacher.classrooms.create!(name: "Turma de validação")

    expect(described_class.new(classroom: classroom, user: create(:user))).to be_valid

    enrollment = described_class.new(classroom: classroom, user: teacher)
    expect(enrollment).to be_invalid
    expect(enrollment.errors[:user]).to include("must be a student")
  end
end
