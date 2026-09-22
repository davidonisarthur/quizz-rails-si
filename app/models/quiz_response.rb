class QuizResponse < ApplicationRecord
  belongs_to :quiz_attempt
  belongs_to :question, optional: true

  validates :selected_index, inclusion: { in: 0..3 }
  validates :correct, inclusion: { in: [ true, false ] }
  validates :question_id, uniqueness: { scope: :quiz_attempt_id }, allow_nil: true
end
