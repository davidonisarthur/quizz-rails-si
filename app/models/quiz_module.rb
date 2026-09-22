class QuizModule < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true
  has_many :questions, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy
  has_many :module_assignments, dependent: :destroy
  has_many :classrooms, through: :module_assignments
  has_many :study_modules, dependent: :nullify

  scope :published, -> { where(published: true) }
  scope :visible_to, ->(user) {
    public_modules = where(platform_default: true).or(where(audience: :public_audience))
    user ? public_modules.or(where(id: ModuleAssignment.joins(:classroom).where(classrooms: { id: user.enrolled_classrooms.select(:id) }).select(:quiz_module_id))) : public_modules
  }

  enum :audience, { public_audience: "public", classroom_audience: "classroom" }, prefix: :audience, validate: true

  validates :title_pt, presence: true
  validates :title_en, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :position, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }

  def available_to?(user)
    return false unless visible_to?(user)
    return false if questions.published.none?
    return true if unlocked?
    return false unless user

    previous_module = QuizModule.where("position < ?", position).order(position: :desc).first
    previous_module.present? && user.quiz_attempts.exists?(quiz_module: previous_module)
  end

  def visible_to?(user)
    platform_default? || audience_public_audience? || (user && user.enrolled_classrooms.joins(:module_assignments).exists?(module_assignments: { quiz_module_id: id }))
  end

  def owned_by?(user)
    created_by_id == user&.id
  end
end
