class HomeController < ApplicationController
  def index
    return redirect_to teacher_root_path(locale: I18n.locale) if current_user&.teacher?

    @modules = QuizModule.published.visible_to(current_user).includes(:questions).order(:position).to_a
    @attempted_module_ids = current_user ? current_user.quiz_attempts.where(quiz_module_id: @modules.map(&:id)).distinct.pluck(:quiz_module_id) : []
    @completed_modules_count = @attempted_module_ids.length
    @completion_percentage = @modules.any? ? ((@completed_modules_count.to_f / @modules.length) * 100).round : 0
    @attempts_count = current_user ? current_user.quiz_attempts.count : 0

    pending_modules = @modules.reject { |quiz_module| @attempted_module_ids.include?(quiz_module.id) }
    @next_module = pending_modules.find { |quiz_module| quiz_module.available_to?(current_user) }
    @next_module ||= @modules.find { |quiz_module| quiz_module.available_to?(current_user) }
  end
end
