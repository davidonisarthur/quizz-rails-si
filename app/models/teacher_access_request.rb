class TeacherAccessRequest < ApplicationRecord
  belongs_to :user
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, { pending: "pending", approved: "approved", rejected: "rejected" }, validate: true
  validates :user_id, uniqueness: { conditions: -> { pending } }
end
