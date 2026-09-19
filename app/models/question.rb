class Question < ApplicationRecord
  belongs_to :quiz_module
  has_many :options, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  validates :body_pt, presence: true
  validates :correct_index, presence: true, inclusion: { in: 0..3 }
  validate :libras_video_url_is_not_placeholder

  def libras_embed_url
    return nil if libras_video_url.blank?

    if libras_video_url =~ /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/ ]+)/
      video_id = $1
      "https://www.youtube.com/embed/#{video_id}"
    else
      nil
    end
  end

  private

  def libras_video_url_is_not_placeholder
    return unless libras_video_url&.include?("dQw4w9WgXcQ")

    errors.add(:libras_video_url, "must reference an approved LIBRAS video")
  end
end
