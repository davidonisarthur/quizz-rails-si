class QuizAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :quiz_module
  has_many :quiz_responses, dependent: :destroy

  validates :score, numericality: { greater_than_or_equal_to: 0 }
end
