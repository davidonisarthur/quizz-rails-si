module Teacher
  class DirectUploadsController < ActiveStorage::DirectUploadsController
    before_action :require_teacher_access

    private

    def require_teacher_access
      user = User.find_by(id: session[:user_id])
      head :forbidden unless user&.teacher? || user&.admin?
    end
  end
end
