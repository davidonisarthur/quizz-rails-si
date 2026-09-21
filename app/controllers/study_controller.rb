class StudyController < ApplicationController
  TOPICS = {
    "turing-machine" => :turing_machine
  }.freeze

  def index
    @topics = TOPICS
    @study_modules = StudyModule.published.order(:position)
  end

  def show
    @topic = TOPICS[params[:slug]]
    return if @topic

    @study_module = StudyModule.published.find_by!(slug: params[:slug])
    render :generic
  end
end
