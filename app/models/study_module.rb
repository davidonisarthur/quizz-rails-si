class StudyModule < ApplicationRecord
  RESERVED_SLUGS = %w[turing-machine].freeze

  belongs_to :created_by, class_name: "User"
  belongs_to :quiz_module, optional: true
  has_rich_text :rich_content_pt
  has_rich_text :rich_content_en

  before_validation :populate_legacy_content_from_rich_text

  scope :published, -> { where(published: true) }

  validates :title_pt, :title_en, :summary_pt, :summary_en,
    :libras_content_pt, :libras_content_en, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
  validates :slug, exclusion: { in: RESERVED_SLUGS }
  validates :position, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }
  validate :video_url_uses_https
  validate :linked_quiz_belongs_to_author
  validate :content_is_present_in_both_languages

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

  def rich_content
    I18n.locale == :en ? rich_content_en : rich_content_pt
  end

  def rich_content_present?
    rich_content.body&.to_plain_text.to_s.squish.present?
  end

  private

  def video_url_uses_https
    return if video_url.blank?

    uri = URI.parse(video_url)
    errors.add(:video_url, :invalid) unless uri.is_a?(URI::HTTPS) && uri.host.present?
  rescue URI::InvalidURIError
    errors.add(:video_url, :invalid)
  end

  def linked_quiz_belongs_to_author
    return unless quiz_module && quiz_module.created_by_id != created_by_id

    errors.add(:quiz_module, :invalid)
  end

  def content_is_present_in_both_languages
    errors.add(:content_pt, :blank) if content_pt.blank? && rich_content_pt.body&.to_plain_text.to_s.squish.blank?
    errors.add(:content_en, :blank) if content_en.blank? && rich_content_en.body&.to_plain_text.to_s.squish.blank?
  end

  def populate_legacy_content_from_rich_text
    self.content_pt = rich_content_pt.body&.to_plain_text.to_s if content_pt.blank? && rich_content_pt.body.present?
    self.content_en = rich_content_en.body&.to_plain_text.to_s if content_en.blank? && rich_content_en.body.present?
  end
end
