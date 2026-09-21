module Teacher
  class ModuleAssignmentsController < BaseController
    before_action :set_module

    def create
      classroom = current_user.classrooms.find(params[:classroom_id])
      @module.module_assignments.create!(classroom: classroom)
      redirect_to teacher_quiz_module_path(@module, locale: I18n.locale), notice: t("classrooms.module_assigned")
    rescue ActiveRecord::RecordInvalid
      redirect_to teacher_quiz_module_path(@module, locale: I18n.locale), alert: t("classrooms.module_already_assigned")
    end

    def destroy
      @module.module_assignments.find(params[:id]).destroy
      redirect_to teacher_quiz_module_path(@module, locale: I18n.locale), notice: t("classrooms.module_unassigned")
    end

    private

    def set_module
      @module = current_user.authored_quiz_modules.find(params[:quiz_module_id])
    end
  end
end
