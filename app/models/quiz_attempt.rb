class QuizAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :quiz_module

  validates :score, numericality: { greater_than_or_equal_to: 0 }
end
