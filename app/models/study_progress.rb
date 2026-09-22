class StudyProgress < ApplicationRecord
  belongs_to :user

  validates :study_slug, presence: true, uniqueness: { scope: :user_id }, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }

  def completed?
    completed_at.present?
  end
end
