module Teacher
  class ClassroomEnrollmentsController < BaseController
    before_action :set_classroom

    def create
      student = User.student.find_by(email: params[:email].to_s.strip.downcase)
      return redirect_to(teacher_classroom_path(@classroom, locale: I18n.locale), alert: t("classrooms.student_not_found")) unless student

      @classroom.classroom_enrollments.create!(user: student)
      redirect_to teacher_classroom_path(@classroom, locale: I18n.locale), notice: t("classrooms.student_added")
    rescue ActiveRecord::RecordInvalid
      redirect_to teacher_classroom_path(@classroom, locale: I18n.locale), alert: t("classrooms.student_already_enrolled")
    end

    def destroy
      @classroom.classroom_enrollments.find(params[:id]).destroy
      redirect_to teacher_classroom_path(@classroom, locale: I18n.locale), notice: t("classrooms.student_removed")
    end

    private

    def set_classroom
      @classroom = current_user.classrooms.find(params[:classroom_id])
    end
  end
end
