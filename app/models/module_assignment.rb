class ModuleAssignment < ApplicationRecord
  belongs_to :classroom
  belongs_to :quiz_module

  validates :quiz_module_id, uniqueness: { scope: :classroom_id }
end
