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
  end
end
