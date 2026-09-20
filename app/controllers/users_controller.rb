class UsersController < ApplicationController
  before_action :require_login, only: [ :profile ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path(locale: I18n.locale)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def profile
    @attempts = current_user.quiz_attempts.includes(:quiz_module).order(created_at: :desc)
    @modules = QuizModule.published.includes(:questions).order(:position).to_a
    attempts_by_module = @attempts.group_by(&:quiz_module_id)

    @module_progress = @modules.map do |quiz_module|
      attempts = attempts_by_module.fetch(quiz_module.id, [])
      question_count = quiz_module.questions.count(&:published?)
      best_attempt = attempts.max_by { |attempt| [ attempt.score, attempt.created_at ] }

      {
        quiz_module: quiz_module,
        question_count: question_count,
        completed: attempts.any?,
        available: quiz_module.available_to?(current_user),
        best_attempt: best_attempt,
        last_attempt: attempts.first,
        best_percentage: best_attempt && question_count.positive? ? ((best_attempt.score.to_f / question_count) * 100).round : nil
      }
    end

    @completed_modules = @module_progress.select { |progress| progress[:completed] }
    @pending_modules = @module_progress.reject { |progress| progress[:completed] }
    @next_module = @pending_modules.find { |progress| progress[:available] }
    @other_pending_modules = @pending_modules.reject { |progress| progress == @next_module }
    @completion_percentage = @modules.any? ? ((@completed_modules.count.to_f / @modules.count) * 100).round : 0
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
