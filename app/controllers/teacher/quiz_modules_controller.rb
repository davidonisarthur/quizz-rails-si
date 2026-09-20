module Teacher
  class QuizModulesController < BaseController
    before_action :set_module, only: %i[show edit update destroy]

    def index
      @modules = current_user.authored_quiz_modules.includes(:questions).order(:position)
    end

    def show; end

    def new
      @module = current_user.authored_quiz_modules.build(published: false, unlocked: false)
    end

    def create
      @module = current_user.authored_quiz_modules.build(module_params)
      save_module
    end

    def edit; end

    def update
      @module.assign_attributes(module_params)
      save_module
    end

    def destroy
      @module.destroy
      redirect_to teacher_quiz_modules_path(locale: I18n.locale), notice: t("teacher.module_deleted")
    end

    private

    def set_module
      @module = current_user.authored_quiz_modules.find(params[:id])
    end

    def module_params
      params.require(:quiz_module).permit(:title_pt, :title_en, :slug, :position, :unlocked, :published)
    end

    def save_module
      if @module.published? && @module.questions.published.none?
        @module.errors.add(:published, t("teacher.module_requires_question"))
        render action_name == "create" ? :new : :edit, status: :unprocessable_entity
      elsif @module.save
        redirect_to teacher_quiz_module_path(@module, locale: I18n.locale), notice: t("teacher.module_saved")
      else
        render action_name == "create" ? :new : :edit, status: :unprocessable_entity
      end
    end
  end
end
