class HomeController < ApplicationController
  def index
    @modules = QuizModule.includes(:questions).order(:position)
  end
end
