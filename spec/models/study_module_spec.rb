require "rails_helper"

RSpec.describe StudyModule, type: :model do
  subject(:study_module) { build(:study_module) }

  it { is_expected.to belong_to(:created_by).class_name("User") }
  it { is_expected.to validate_presence_of(:title_pt) }
  it { is_expected.to validate_presence_of(:title_en) }
  it { is_expected.to validate_presence_of(:content_pt) }
  it { is_expected.to validate_presence_of(:libras_content_pt) }
  it { is_expected.to validate_uniqueness_of(:slug) }
  it { is_expected.to validate_uniqueness_of(:position) }

  it "does not allow the static Turing machine slug to be replaced" do
    study_module.slug = "turing-machine"

    expect(study_module).to be_invalid
    expect(study_module.errors[:slug]).to be_present
  end

  it "accepts only HTTPS video links" do
    study_module.video_url = "http://example.com/video"
    expect(study_module).to be_invalid

    study_module.video_url = "https://example.com/video"
    expect(study_module).to be_valid
  end

  it "selects the content for the current locale" do
    I18n.with_locale(:en) do
      expect(study_module.title).to eq(study_module.title_en)
      expect(study_module.content).to eq(study_module.content_en)
      expect(study_module.libras_content).to eq(study_module.libras_content_en)
    end
  end

  it "only allows a quiz authored by the same teacher" do
    study_module.quiz_module = create(:quiz_module, created_by: create(:user, :teacher))

    expect(study_module).to be_invalid
    expect(study_module.errors[:quiz_module]).to be_present
  end
end
