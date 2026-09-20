class HomeController < ApplicationController
  def index
    @modules = QuizModule.published.includes(:questions).order(:position)
  end
end
