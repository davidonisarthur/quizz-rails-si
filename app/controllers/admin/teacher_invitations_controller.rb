module Admin
  class TeacherInvitationsController < BaseController
    def index
      @invitations = TeacherInvitation.order(created_at: :desc).limit(20)
    end

    def create
      _, token = TeacherInvitation.issue!(email: params.require(:email), invited_by: current_user)
      redirect_to admin_teacher_invitations_path(locale: I18n.locale), notice: t("teacher_invitations.created"), flash: { invitation_url: new_user_url(locale: I18n.locale, invitation_token: token) }
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_teacher_invitations_path(locale: I18n.locale), alert: t("teacher_invitations.invalid")
    end
  end
end
