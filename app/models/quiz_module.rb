class QuizModule < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy

  validates :title_pt, presence: true
  validates :title_en, presence: true
  validates :slug, presence: true, uniqueness: true
end
