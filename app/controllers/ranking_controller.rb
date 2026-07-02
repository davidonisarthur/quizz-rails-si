class RankingController < ApplicationController
  before_action :require_login

  def index
    @ranking = User
      .joins(:quiz_attempts)
      .select("users.id, users.name, SUM(quiz_attempts.score) AS total_score")
      .group("users.id, users.name")
      .order("total_score DESC")
      .limit(20)
  end
end
