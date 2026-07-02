class Question < ApplicationRecord
  belongs_to :quiz_module
  has_many :options, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  validates :body_pt, presence: true
  validates :correct_index, presence: true, inclusion: { in: 0..3 }

  def libras_embed_url
    return nil if libras_video_url.blank?
    
    if libras_video_url =~ /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/ ]+)/
      video_id = $1
      "https://www.youtube.com/embed/#{video_id}"
    else
      nil
    end
  end
end
