module Teacher
  class StudyModuleAssignmentsController < BaseController
    before_action :set_study_module

    def create
      classroom = current_user.classrooms.find(params[:classroom_id])
      @study_module.study_module_assignments.create!(classroom: classroom)
      redirect_to teacher_study_module_path(@study_module, locale: I18n.locale), notice: t("classrooms.study_assigned")
    rescue ActiveRecord::RecordInvalid
      redirect_to teacher_study_module_path(@study_module, locale: I18n.locale), alert: t("classrooms.study_already_assigned")
    end

    def destroy
      @study_module.study_module_assignments.find(params[:id]).destroy
      redirect_to teacher_study_module_path(@study_module, locale: I18n.locale), notice: t("classrooms.study_unassigned")
    end

    private

    def set_study_module
      @study_module = current_user.authored_study_modules.where(platform_default: false).find(params[:study_module_id])
    end
  end
end
