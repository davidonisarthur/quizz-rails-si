module LibrasVideoAttachment
  extend ActiveSupport::Concern

  ALLOWED_LIBRAS_VIDEO_CONTENT_TYPES = %w[video/mp4 video/webm video/ogg].freeze
  MAX_LIBRAS_VIDEO_SIZE = 150.megabytes

  included do
    has_one_attached :libras_video

    validate :libras_video_is_valid
  end

  private

  def libras_video_is_valid
    return unless libras_video.attached?

    unless ALLOWED_LIBRAS_VIDEO_CONTENT_TYPES.include?(libras_video.content_type)
      errors.add(:libras_video, I18n.t("uploads.libras_video.invalid_type"))
    end

    return unless libras_video.byte_size > MAX_LIBRAS_VIDEO_SIZE

    errors.add(:libras_video, I18n.t("uploads.libras_video.too_large", size: MAX_LIBRAS_VIDEO_SIZE / 1.megabyte))
  end
end
