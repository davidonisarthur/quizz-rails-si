class QuizModule < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy

  validates :title_pt, presence: true
  validates :title_en, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :position, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }

  def available_to?(user)
    return false if questions.none?
    return true if unlocked?
    return false unless user

    previous_module = QuizModule.where("position < ?", position).order(position: :desc).first
    previous_module.present? && user.quiz_attempts.exists?(quiz_module: previous_module)
  end
end
