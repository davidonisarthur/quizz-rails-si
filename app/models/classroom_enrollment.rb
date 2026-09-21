class ClassroomEnrollment < ApplicationRecord
  belongs_to :classroom
  belongs_to :user

  validates :user_id, uniqueness: { scope: :classroom_id }
  validate :user_is_student

  private

  def user_is_student
    errors.add(:user, "must be a student") if user && !user.student?
  end
end
