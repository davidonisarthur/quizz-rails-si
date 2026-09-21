class StudyModuleAssignment < ApplicationRecord
  belongs_to :classroom
  belongs_to :study_module

  validates :study_module_id, uniqueness: { scope: :classroom_id }
  validate :classroom_belongs_to_study_module_author

  private

  def classroom_belongs_to_study_module_author
    return unless classroom && study_module
    return if classroom.teacher_id == study_module.created_by_id && !study_module.platform_default?

    errors.add(:classroom, :invalid)
  end
end
