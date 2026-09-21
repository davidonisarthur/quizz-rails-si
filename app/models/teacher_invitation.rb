class TeacherInvitation < ApplicationRecord
  belongs_to :invited_by, class_name: "User"
  belongs_to :accepted_by, class_name: "User", optional: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token_digest, uniqueness: true

  def self.issue!(email:, invited_by:)
    token = SecureRandom.urlsafe_base64(32)
    invitation = create!(email: email.strip.downcase, invited_by: invited_by, token_digest: digest(token), expires_at: 7.days.from_now)
    [ invitation, token ]
  end

  def self.find_valid(token)
    find_by(token_digest: digest(token.to_s), accepted_at: nil)&.then { |invitation| invitation if invitation.expires_at.future? }
  end

  def self.digest(token)
    Digest::SHA256.hexdigest(token)
  end
end
