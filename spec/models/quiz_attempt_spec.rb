require 'rails_helper'

RSpec.describe QuizAttempt, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:quiz_module) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:score).is_greater_than_or_equal_to(0) }

    it "é inválido com score negativo" do
      attempt = build(:quiz_attempt, score: -1)
      expect(attempt).not_to be_valid
    end

    it "é válido com score zero" do
      attempt = build(:quiz_attempt, score: 0)
      expect(attempt).to be_valid
    end
  end
end
