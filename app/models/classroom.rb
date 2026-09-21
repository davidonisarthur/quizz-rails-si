class Classroom < ApplicationRecord
  belongs_to :teacher, class_name: "User"
  has_many :classroom_enrollments, dependent: :destroy
  has_many :students, through: :classroom_enrollments, source: :user
  has_many :module_assignments, dependent: :destroy
  has_many :quiz_modules, through: :module_assignments

  validates :name, presence: true
end
