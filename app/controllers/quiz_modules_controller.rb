class QuizModulesController < ApplicationController
  def index
    return redirect_to teacher_root_path(locale: I18n.locale) if current_user&.teacher?

    @modules = QuizModule.published.visible_to(current_user).includes(:questions).order(:position)
  end
end
