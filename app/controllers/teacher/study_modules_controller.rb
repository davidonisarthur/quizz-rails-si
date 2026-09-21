module Teacher
  class StudyModulesController < BaseController
    before_action :set_study_module, only: %i[show edit update destroy]

    def index
      @study_modules = current_user.authored_study_modules.order(:position)
    end

    def show; end

    def new
      @study_module = current_user.authored_study_modules.build(published: false)
    end

    def create
      @study_module = current_user.authored_study_modules.build(study_module_params)
      save_study_module
    end

    def edit; end

    def update
      @study_module.assign_attributes(study_module_params)
      save_study_module
    end

    def destroy
      @study_module.destroy
      redirect_to teacher_study_modules_path(locale: I18n.locale), notice: t("study.management.deleted")
    end

    private

    def set_study_module
      @study_module = current_user.authored_study_modules.find(params[:id])
    end

    def study_module_params
      params.require(:study_module).permit(
        :title_pt, :title_en, :summary_pt, :summary_en, :content_pt, :content_en,
        :libras_content_pt, :libras_content_en, :video_url, :quiz_module_id, :slug, :position, :published
      )
    end

    def save_study_module
      if @study_module.save
        redirect_to teacher_study_module_path(@study_module, locale: I18n.locale), notice: t("study.management.saved")
      else
        render action_name == "create" ? :new : :edit, status: :unprocessable_entity
      end
    end
  end
end
