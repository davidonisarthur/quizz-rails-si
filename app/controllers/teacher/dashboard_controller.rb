module Teacher
  class DashboardController < BaseController
    def index
      @modules = current_user.authored_quiz_modules.includes(:questions).order(:position)
      @study_modules = current_user.authored_study_modules.order(:position)
      @classrooms_count = current_user.classrooms.count
      @students_count = ClassroomEnrollment.where(classroom_id: current_user.classrooms.select(:id)).distinct.count(:user_id)
      @published_content_count = @modules.count(&:published?) + @study_modules.count(&:published?)
      @drafts_count = @modules.count { |quiz_module| !quiz_module.published? } + @study_modules.count { |study_module| !study_module.published? }
      @next_step = next_step
    end

    private

    def next_step
      return :create_classroom if @classrooms_count.zero?
      return :create_content if @modules.empty? && @study_modules.empty?
      return :add_questions if @modules.any? { |quiz_module| quiz_module.questions.empty? }
      return :review_drafts if @drafts_count.positive?

      :review_results
    end
  end
end
