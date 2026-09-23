require "rails_helper"

RSpec.describe StudyModule, type: :model do
  subject(:study_module) { build(:study_module) }

  it { is_expected.to belong_to(:created_by).class_name("User") }
  it { is_expected.to have_many(:study_module_assignments).dependent(:destroy) }
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

  it "rejects malformed video links without raising a URI error" do
    study_module.video_url = "https://[invalid-url"

    expect(study_module).to be_invalid
    expect(study_module.errors[:video_url]).to be_present
  end

  it "selects the content for the current locale" do
    I18n.with_locale(:en) do
      expect(study_module.title).to eq(study_module.title_en)
      expect(study_module.summary).to eq(study_module.summary_en)
      expect(study_module.content).to eq(study_module.content_en)
      expect(study_module.libras_content).to eq(study_module.libras_content_en)
    end
  end

  it "selects the Portuguese title, summary, and rich content by default" do
    study_module.rich_content_pt = "<div>Texto rico em português.</div>"
    study_module.rich_content_en = "<div>Rich English text.</div>"

    I18n.with_locale(:"pt-BR") do
      expect(study_module.title).to eq(study_module.title_pt)
      expect(study_module.summary).to eq(study_module.summary_pt)
      expect(study_module.rich_content.to_plain_text).to include("Texto rico em português")
    end
  end

  it "only allows a quiz authored by the same teacher" do
    study_module.quiz_module = create(:quiz_module, created_by: create(:user, :teacher))

    expect(study_module).to be_invalid
    expect(study_module.errors[:quiz_module]).to be_present
  end

  it "limits classroom-only content to enrolled students while keeping platform content public" do
    teacher = create(:user, :teacher)
    enrolled_student = create(:user)
    other_student = create(:user)
    classroom = teacher.classrooms.create!(name: "Turma de estudo")
    classroom.classroom_enrollments.create!(user: enrolled_student)
    restricted_module = create(:study_module, created_by: teacher, audience: "classroom_audience")
    StudyModuleAssignment.create!(classroom: classroom, study_module: restricted_module)
    platform_module = create(:study_module, created_by: teacher, audience: "classroom_audience", platform_default: true)

    expect(restricted_module).not_to be_visible_to(nil)
    expect(restricted_module).to be_visible_to(enrolled_student)
    expect(restricted_module).not_to be_visible_to(other_student)
    expect(platform_module).to be_visible_to(nil)
  end

  it "rejects an assignment to a classroom owned by another teacher" do
    author = create(:user, :teacher)
    other_teacher = create(:user, :teacher)
    restricted_module = create(:study_module, created_by: author, audience: "classroom_audience")
    foreign_classroom = other_teacher.classrooms.create!(name: "Turma externa")

    assignment = StudyModuleAssignment.new(classroom: foreign_classroom, study_module: restricted_module)

    expect(assignment).to be_invalid
    expect(assignment.errors[:classroom]).to be_present
  end

  it "rejects assigning platform study content to the classroom of its author" do
    teacher = create(:user, :teacher)
    classroom = teacher.classrooms.create!(name: "Turma da plataforma")
    platform_study = create(:study_module, created_by: teacher, platform_default: true)

    assignment = StudyModuleAssignment.new(classroom: classroom, study_module: platform_study)

    expect(assignment).to be_invalid
    expect(assignment.errors[:classroom]).to be_present
  end

  it "does not run the classroom ownership validation before both records exist" do
    assignment = StudyModuleAssignment.new

    expect(assignment).to be_invalid
    expect(assignment.errors[:classroom]).to contain_exactly("must exist")
  end

  it "requires both plain or rich content fields to contain text" do
    study_module.content_pt = ""
    study_module.content_en = ""

    expect(study_module).to be_invalid
    expect(study_module.errors[:content_pt]).to be_present
    expect(study_module.errors[:content_en]).to be_present
  end

  it "keeps legacy text when it is already provided" do
    expect(study_module).to be_valid
    expect(study_module.content_pt).to be_present
    expect(study_module.content_en).to be_present
  end

  it "accepts rich content without requiring the legacy plain-text fields" do
    study_module.content_pt = ""
    study_module.content_en = ""
    study_module.rich_content_pt = "<h1>Seção em português</h1><div>Texto com <strong>destaque</strong>.</div>"
    study_module.rich_content_en = "<h1>English section</h1><div>Text with <strong>emphasis</strong>.</div>"

    expect { study_module.save! }.not_to raise_error
    expect(study_module).to be_rich_content_present
    expect(study_module.content_pt).to include("Seção em português")
    expect(study_module.content_en).to include("English section")
  end
end
