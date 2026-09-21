module Teacher
  class DashboardController < BaseController
    def index
      @modules = current_user.authored_quiz_modules.includes(:questions).order(:position)
      @study_modules = current_user.authored_study_modules.order(:position)
    end
  end
end
