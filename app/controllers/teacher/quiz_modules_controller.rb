module Teacher
  class QuizModulesController < BaseController
    before_action :set_module, only: %i[show edit update destroy preview report]

    def index
      @modules = current_user.authored_quiz_modules.includes(:questions).order(:position)
    end

    def show; end

    def preview
      @questions = @module.questions.includes(:options).order(:position)
    end

    def report
      @question_count = @module.questions.published.count
      @attempts = @module.quiz_attempts.includes(:user).order(created_at: :desc)
      @attempts_count = @attempts.count
      @students_count = @attempts.distinct.count(:user_id)
      @average_score = @attempts.average(:score).to_f.round(1)
      @average_percentage = @question_count.positive? ? ((@average_score / @question_count) * 100).round : 0

      @question_stats = @module.questions.published
        .left_joins(:quiz_responses)
        .select("questions.*, COUNT(quiz_responses.id) AS responses_count, COALESCE(SUM(CASE WHEN quiz_responses.correct THEN 1 ELSE 0 END), 0) AS correct_responses_count")
        .group("questions.id")
        .to_a
        .sort_by do |question|
          responses_count = question.responses_count.to_i
          [ responses_count.zero? ? 2 : question.correct_responses_count.to_f / responses_count, question.position ]
        end
    end

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
