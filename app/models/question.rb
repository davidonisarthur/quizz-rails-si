class Question < ApplicationRecord
  belongs_to :quiz_module
  has_many :options, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  validates :body_pt, presence: true
  validates :correct_index, presence: true, inclusion: { in: 0..3 }
end
