class User < ApplicationRecord
  has_secure_password

  has_many :quiz_attempts, dependent: :destroy
  has_many :quiz_modules, through: :quiz_attempts

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
end
