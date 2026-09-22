module Teacher
  class ClassroomsController < BaseController
    before_action :set_classroom, only: %i[show destroy]

    def index
      @classrooms = current_user.classrooms.includes(:students, :quiz_modules).order(:name)
      @classroom = current_user.classrooms.build
    end

    def show; end

    def create
      @classroom = current_user.classrooms.build(classroom_params)
      if @classroom.save
        redirect_to teacher_classroom_path(@classroom, locale: I18n.locale), notice: t("classrooms.created")
      else
        @classrooms = current_user.classrooms.includes(:students, :quiz_modules).order(:name)
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      if @classroom.destroy
        redirect_to teacher_classrooms_path(locale: I18n.locale), notice: t("classrooms.deleted")
      else
        redirect_to teacher_classroom_path(@classroom, locale: I18n.locale), alert: @classroom.errors.full_messages.to_sentence
      end
    end

    private

    def set_classroom
      @classroom = current_user.classrooms.find(params[:id])
    end

    def classroom_params
      params.require(:classroom).permit(:name)
    end
  end
end
