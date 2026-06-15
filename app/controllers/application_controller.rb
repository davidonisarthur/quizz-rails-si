class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :set_locale

  private

  def set_locale
    locale = params[:locale] || session[:locale] || "pt-BR"
    I18n.locale = locale if %w[pt-BR en].include?(locale)
    session[:locale] = I18n.locale
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def require_login
    redirect_to new_session_path(locale: I18n.locale) unless current_user
  end
end
