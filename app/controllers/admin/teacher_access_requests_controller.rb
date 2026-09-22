module Admin
  class TeacherAccessRequestsController < BaseController
    def index
      @requests = TeacherAccessRequest.pending.includes(:user).order(created_at: :asc)
    end

    def approve
      review("approved") { |request| request.user.update!(role: "teacher") }
    end

    def reject
      review("rejected")
    end

    private

    def review(status)
      request = TeacherAccessRequest.pending.find(params[:id])
      TeacherAccessRequest.transaction do
        request.lock!
        yield request if block_given?
        request.update!(status: status, reviewed_by: current_user, reviewed_at: Time.current)
      end
      redirect_to admin_teacher_access_requests_path(locale: I18n.locale), notice: t("teacher_requests.reviewed")
    end
  end
end
