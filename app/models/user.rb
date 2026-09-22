class User < ApplicationRecord
  has_secure_password

  has_many :quiz_attempts, dependent: :destroy
  has_many :quiz_modules, through: :quiz_attempts
  has_many :authored_quiz_modules, class_name: "QuizModule", foreign_key: :created_by_id, dependent: :restrict_with_error
  has_many :authored_study_modules, class_name: "StudyModule", foreign_key: :created_by_id, dependent: :restrict_with_error
  has_many :classrooms, foreign_key: :teacher_id, dependent: :destroy
  has_many :classroom_enrollments, dependent: :destroy
  has_many :enrolled_classrooms, through: :classroom_enrollments, source: :classroom
  has_many :teacher_access_requests, dependent: :destroy
  has_many :study_progresses, dependent: :destroy

  enum :role, { student: "student", teacher: "teacher", admin: "admin" }, validate: true

  before_validation { self.email = email.to_s.strip.downcase if email.present? }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
end
