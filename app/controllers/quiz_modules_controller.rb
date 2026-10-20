class QuizModulesController < ApplicationController
  def index
    return redirect_to teacher_root_path(locale: I18n.locale) if current_user&.teacher?

    @modules = QuizModule.published.visible_to(current_user).includes(:questions).order(:position).to_a
    @attempted_module_ids = if current_user
      current_user.quiz_attempts.where(quiz_module_id: @modules.map(&:id)).distinct.pluck(:quiz_module_id)
    else
      []
    end
    @completed_modules_count = @attempted_module_ids.length
    @completion_percentage = if @modules.any?
      ((@completed_modules_count.to_f / @modules.length) * 100).round
    else
      0
    end
  end
end
