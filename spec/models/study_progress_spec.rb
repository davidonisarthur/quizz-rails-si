require "rails_helper"

RSpec.describe StudyProgress, type: :model do
  subject(:progress) { described_class.new(user: create(:user), study_slug: "turing-machine", started_at: Time.current, last_accessed_at: Time.current) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:study_slug) }

  it "allows only one progress record per study and user" do
    progress.save!
    duplicate = progress.dup

    expect(duplicate).to be_invalid
    expect(duplicate.errors[:study_slug]).to be_present
  end

  it "identifies completed studies" do
    expect(progress).not_to be_completed
    progress.completed_at = Time.current
    expect(progress).to be_completed
  end
end
