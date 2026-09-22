class ModuleAssignment < ApplicationRecord
  belongs_to :classroom
  belongs_to :quiz_module

  validates :quiz_module_id, uniqueness: { scope: :classroom_id }
  validate :classroom_belongs_to_quiz_author

  private

  def classroom_belongs_to_quiz_author
    return unless classroom && quiz_module
    return if classroom.teacher_id == quiz_module.created_by_id && !quiz_module.platform_default?

    errors.add(:classroom, :invalid)
  end
end
