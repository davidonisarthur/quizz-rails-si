module Teacher
  class BaseController < ApplicationController
    before_action :require_teacher
  end
end
