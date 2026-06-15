class HomeController < ApplicationController
  def index
    @modules = QuizModule.all
  end
end
