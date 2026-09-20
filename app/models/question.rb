class Question < ApplicationRecord
  belongs_to :quiz_module
  has_many :options, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  scope :published, -> { where(published: true) }

  accepts_nested_attributes_for :options, :feedbacks

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

  def ready_to_publish?
    option_list = options.reject(&:marked_for_destruction?)
    feedback_list = feedbacks.reject(&:marked_for_destruction?)

    body_pt.present? && body_en.present? &&
      option_list.size == 4 &&
      option_list.all? { |option| option.text_pt.present? && option.text_en.present? } &&
      feedback_list.map(&:kind).sort == %w[correct incorrect] &&
      feedback_list.all? { |feedback| feedback.body_pt.present? && feedback.body_en.present? }
  end

  private

  def libras_video_url_is_not_placeholder
    return unless libras_video_url&.include?("dQw4w9WgXcQ")

    errors.add(:libras_video_url, "must reference an approved LIBRAS video")
  end
end
