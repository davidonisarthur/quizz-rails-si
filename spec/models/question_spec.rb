require "rails_helper"
require "stringio"

RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should belong_to(:quiz_module) }
    it { should have_many(:options).dependent(:destroy) }
    it { should have_many(:feedbacks).dependent(:destroy) }
    it { should have_one_attached(:libras_video) }
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

  describe "LIBRAS video attachment" do
    it "accepts a platform-hosted MP4 video" do
      question = build(:question)
      question.libras_video.attach(io: StringIO.new("video"), filename: "libras.mp4", content_type: "video/mp4")

      expect(question).to be_valid
      expect(question.libras_video).to be_attached
    end

    it "rejects files that are not supported video formats" do
      question = build(:question)
      question.libras_video.attach(io: StringIO.new("not a video"), filename: "notes.txt", content_type: "text/plain")

      expect(question).not_to be_valid
      expect(question.errors[:libras_video]).to include(I18n.t("uploads.libras_video.invalid_type"))
    end

    it "rejects videos larger than the upload limit" do
      question = build(:question)
      question.libras_video.attach(io: StringIO.new("video"), filename: "large.mp4", content_type: "video/mp4")
      allow(question.libras_video.blob).to receive(:byte_size).and_return(LibrasVideoAttachment::MAX_LIBRAS_VIDEO_SIZE + 1)

      expect(question).not_to be_valid
      expect(question.errors[:libras_video]).to include(I18n.t("uploads.libras_video.too_large", size: 150))
    end
  end

  describe "#ready_to_publish?" do
    it "requires bilingual options and both bilingual feedback messages" do
      question = create(:question)
      4.times { create(:option, question: question, text_en: "Option") }
      create(:feedback, question: question, kind: "correct", body_en: "Correct")
      create(:feedback, question: question, kind: "incorrect", body_en: "Incorrect")

      expect(question).to be_ready_to_publish

      question.options.first.update!(text_en: nil)
      expect(question).not_to be_ready_to_publish
    end
  end
end
