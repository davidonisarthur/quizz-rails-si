class StudyController < ApplicationController
  TOPICS = {
    "turing-machine" => :turing_machine
  }.freeze

  def index
    @topics = TOPICS
  end

  def show
    @topic = TOPICS[params[:slug]]
    raise ActionController::RoutingError, "Not Found" unless @topic
  end
end
