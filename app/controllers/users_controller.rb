class UsersController < ApplicationController
  before_action :require_login, only: [:profile]

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
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
