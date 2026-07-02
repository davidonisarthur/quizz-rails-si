class Option < ApplicationRecord
  belongs_to :question

  validates :text_pt, presence: true
end
