class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      preserved_locale = session[:locale]
      preserved_libras = session[:libras_mode]

      reset_session

      session[:user_id] = user.id
      session[:locale] = preserved_locale if preserved_locale.present?
      session[:libras_mode] = preserved_libras if preserved_libras.present?

      redirect_to root_path(locale: I18n.locale)
    else
      flash.now[:alert] = t("sessions.invalid")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path(locale: I18n.locale)
  end
end
