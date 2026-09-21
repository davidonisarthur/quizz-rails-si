class TeacherAccessRequestsController < ApplicationController
  before_action :require_login

  def create
    return redirect_to(profile_path(locale: I18n.locale), alert: t("teacher_requests.already_teacher")) unless current_user.student?

    current_user.teacher_access_requests.create!
    redirect_to profile_path(locale: I18n.locale), notice: t("teacher_requests.created")
  rescue ActiveRecord::RecordInvalid
    redirect_to profile_path(locale: I18n.locale), alert: t("teacher_requests.already_pending")
  end
end
