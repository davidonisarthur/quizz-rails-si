require 'rails_helper'

RSpec.describe QuizModule, type: :model do
  describe 'associations' do
    it { should have_many(:questions).dependent(:destroy) }
    it { should have_many(:quiz_attempts).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:quiz_module) }

    it { should validate_presence_of(:title_pt) }
    it { should validate_presence_of(:title_en) }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }
    it { should validate_presence_of(:position) }
    it { should validate_uniqueness_of(:position) }
    it { should validate_numericality_of(:position).only_integer.is_greater_than(0) }
  end

  describe "#available_to?" do
    it "makes a base module with questions available to guests" do
      quiz_module = create(:quiz_module, unlocked: true)
      create(:question, quiz_module: quiz_module)

      expect(quiz_module).to be_available_to(nil)
    end

    it "unlocks a sequential module after the user completes the previous one" do
      first_module = create(:quiz_module, position: 1, unlocked: true)
      second_module = create(:quiz_module, position: 2, unlocked: false)
      create(:question, quiz_module: second_module)
      user = create(:user)

      expect(second_module).not_to be_available_to(user)

      create(:quiz_attempt, user: user, quiz_module: first_module, score: 0)

      expect(second_module).to be_available_to(user)
    end
  end

  describe "platform defaults" do
    it "remain visible even if their audience value is changed" do
      quiz_module = create(:quiz_module, platform_default: true, audience: "classroom_audience")

      expect(quiz_module).to be_visible_to(nil)
      expect(QuizModule.visible_to(nil)).to include(quiz_module)
    end
  end

  it "rejects assigning a quiz to a classroom owned by another teacher" do
    author = create(:user, :teacher)
    other_teacher = create(:user, :teacher)
    quiz_module = create(:quiz_module, created_by: author)
    foreign_classroom = other_teacher.classrooms.create!(name: "Turma externa")

    assignment = ModuleAssignment.new(classroom: foreign_classroom, quiz_module: quiz_module)

    expect(assignment).to be_invalid
    expect(assignment.errors[:classroom]).to be_present
  end

  describe "#owned_by?" do
    it "matches only its author" do
      author = create(:user, :teacher)
      quiz_module = create(:quiz_module, created_by: author)

      expect(quiz_module).to be_owned_by(author)
      expect(quiz_module).not_to be_owned_by(create(:user, :teacher))
      expect(quiz_module).not_to be_owned_by(nil)
    end
  end
end
