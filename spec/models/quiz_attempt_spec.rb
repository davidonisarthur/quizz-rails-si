require 'rails_helper'

RSpec.describe QuizAttempt, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:quiz_module) }
  end
end
