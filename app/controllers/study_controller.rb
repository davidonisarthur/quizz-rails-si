class StudyController < ApplicationController
  TOPICS = {
    "turing-machine" => :turing_machine
  }.freeze

  def index
    @topics = TOPICS
    @study_modules = StudyModule.published.order(:position)
    @study_progresses = current_user ? current_user.study_progresses.index_by(&:study_slug) : {}
  end

  def show
    @topic = TOPICS[params[:slug]]
    @study_module = StudyModule.published.find_by(slug: params[:slug]) unless @topic
    raise ActiveRecord::RecordNotFound unless @topic || @study_module

    @study_progress = current_user&.study_progresses&.find_by(study_slug: params[:slug])
    render :generic unless @topic
  end
end
