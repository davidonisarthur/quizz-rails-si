require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:quiz_attempts).dependent(:destroy) }
    it { should have_many(:quiz_modules).through(:quiz_attempts) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should have_secure_password }

    it "é inválido sem email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it "não aceita email duplicado" do
      create(:user, email: "teste@email.com")
      user = build(:user, email: "teste@email.com")
      expect(user).not_to be_valid
    end

    it "authenticate retorna false com senha errada" do
      user = create(:user, password: "senha123")
      expect(user.authenticate("errada")).to be_falsey
    end

    it "authenticate retorna o user com senha correta" do
      user = create(:user, password: "senha123")
      expect(user.authenticate("senha123")).to eq(user)
    end
  end
end
