class QuizModulesController < ApplicationController
  def index
    @modules = QuizModule.published.visible_to(current_user).includes(:questions).order(:position)
  end
end
