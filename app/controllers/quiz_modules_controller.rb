class QuizModulesController < ApplicationController
  def index
    @modules = QuizModule.all
  end
end
