class LibrasModeController < ApplicationController
  def toggle
    session[:libras_mode] = !session[:libras_mode]
    redirect_back fallback_location: root_path
  end
end
