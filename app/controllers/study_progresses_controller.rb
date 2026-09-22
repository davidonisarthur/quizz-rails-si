class StudyProgressesController < ApplicationController
  before_action :require_login

  def create
    study_slug = params[:slug]
    ensure_study_is_available!(study_slug)

    progress = current_user.study_progresses.find_or_initialize_by(study_slug: study_slug)
    progress.started_at ||= Time.current
    progress.last_accessed_at = Time.current
    progress.completed_at = Time.current if params[:status] == "completed"
    progress.save!

    redirect_back fallback_location: study_topic_path(study_slug, locale: I18n.locale), notice: t("study.progress.saved")
  end

  private

  def ensure_study_is_available!(study_slug)
    return if StudyController::TOPICS.key?(study_slug)
    return if StudyModule.published.visible_to(current_user).exists?(slug: study_slug)

    raise ActiveRecord::RecordNotFound
  end
end
