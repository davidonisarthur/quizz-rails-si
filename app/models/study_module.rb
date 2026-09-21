class StudyModule < ApplicationRecord
  RESERVED_SLUGS = %w[turing-machine].freeze

  belongs_to :created_by, class_name: "User"

  scope :published, -> { where(published: true) }

  validates :title_pt, :title_en, :summary_pt, :summary_en, :content_pt, :content_en,
    :libras_content_pt, :libras_content_en, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
  validates :slug, exclusion: { in: RESERVED_SLUGS }
  validates :position, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }
  validate :video_url_uses_https

  def title
    I18n.locale == :en ? title_en : title_pt
  end

  def summary
    I18n.locale == :en ? summary_en : summary_pt
  end

  def content
    I18n.locale == :en ? content_en : content_pt
  end

  def libras_content
    I18n.locale == :en ? libras_content_en : libras_content_pt
  end

  private

  def video_url_uses_https
    return if video_url.blank?

    uri = URI.parse(video_url)
    errors.add(:video_url, :invalid) unless uri.is_a?(URI::HTTPS) && uri.host.present?
  rescue URI::InvalidURIError
    errors.add(:video_url, :invalid)
  end
end
