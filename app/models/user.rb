class User < ApplicationRecord
  has_secure_password

  has_many :quiz_attempts, dependent: :destroy
  has_many :quiz_modules, through: :quiz_attempts
  has_many :authored_quiz_modules, class_name: "QuizModule", foreign_key: :created_by_id, dependent: :restrict_with_error

  enum :role, { student: "student", teacher: "teacher" }, validate: true

  before_validation { self.email = email.to_s.strip.downcase if email.present? }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
end
