class Feedback < ApplicationRecord
  belongs_to :question

  validates :kind, presence: true, inclusion: { in: %w[correct incorrect] }
  validates :kind, uniqueness: { scope: :question_id }
  validates :body_pt, presence: true
end
