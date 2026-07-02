require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should belong_to(:quiz_module) }
    it { should have_many(:options).dependent(:destroy) }
    it { should have_many(:feedbacks).dependent(:destroy) }
  end

  describe 'validations' do
    it "é inválida sem body_pt" do
      question = build(:question, body_pt: nil)
      expect(question).not_to be_valid
    end

    it "é inválida sem correct_index" do
      question = build(:question, correct_index: nil)
      expect(question).not_to be_valid
    end

    it "é inválida se correct_index estiver fora de 0..3" do
      question = build(:question, correct_index: 5)
      expect(question).not_to be_valid
    end

    it "é válida com todos os campos obrigatórios" do
      question = build(:question)
      expect(question).to be_valid
    end

    # Also using shoulda-matchers for completeness
    it { should validate_presence_of(:body_pt) }
    it { should validate_presence_of(:correct_index) }
    it { should validate_inclusion_of(:correct_index).in_range(0..3) }
  end

  describe '#libras_embed_url' do
    it "returns nil if libras_video_url is nil or blank" do
      expect(build(:question, libras_video_url: nil).libras_embed_url).to be_nil
      expect(build(:question, libras_video_url: "").libras_embed_url).to be_nil
    end

    it "correctly parses standard watch URLs" do
      question = build(:question, libras_video_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
      expect(question.libras_embed_url).to eq("https://www.youtube.com/embed/dQw4w9WgXcQ")
    end

    it "correctly parses youtu.be short URLs" do
      question = build(:question, libras_video_url: "https://youtu.be/dQw4w9WgXcQ?t=12")
      expect(question.libras_embed_url).to eq("https://www.youtube.com/embed/dQw4w9WgXcQ")
    end

    it "correctly parses embed URLs directly" do
      question = build(:question, libras_video_url: "https://www.youtube.com/embed/dQw4w9WgXcQ")
      expect(question.libras_embed_url).to eq("https://www.youtube.com/embed/dQw4w9WgXcQ")
    end

    it "handles non-standard test IDs from factory" do
      question = build(:question, libras_video_url: "https://youtube.com/watch?v=exemplo")
      expect(question.libras_embed_url).to eq("https://www.youtube.com/embed/exemplo")
    end
  end
end
