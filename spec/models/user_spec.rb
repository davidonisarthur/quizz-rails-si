require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:quiz_attempts).dependent(:destroy) }
    it { should have_many(:quiz_modules).through(:quiz_attempts) }
  end

  describe 'validations' do
    subject { FactoryBot.build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should have_secure_password }
  end
end
