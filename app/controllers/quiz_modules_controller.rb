class QuizModulesController < ApplicationController
  def index
    @modules = QuizModule.includes(:questions).order(:position)
  end
end
