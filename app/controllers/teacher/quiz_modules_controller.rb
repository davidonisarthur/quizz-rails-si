module Teacher
  class QuizModulesController < BaseController
    before_action :set_module, only: %i[show edit update destroy preview report]

    def index
      @modules = current_user.authored_quiz_modules.where(platform_default: false).includes(:questions).order(:position)
    end

    def show
      @classrooms = current_user.classrooms.order(:name)
      @assignments = @module.module_assignments.includes(:classroom)
    end

    def preview
      @questions = @module.questions.includes(:options).order(:position)
    end

    def report
      @question_count = @module.questions.published.count
      @report_classrooms = current_user.classrooms.joins(:module_assignments).where(module_assignments: { quiz_module_id: @module.id }).order(:name)
      @selected_classroom = @report_classrooms.find(params[:classroom_id]) if params[:classroom_id].present?
      @report_attempts = @module.quiz_attempts
      @report_attempts = @report_attempts.where(user_id: @selected_classroom.students.select(:id)) if @selected_classroom
      @attempts = @report_attempts.includes(:user).order(created_at: :desc)
      @attempts_count = @attempts.count
      @students_count = @attempts.distinct.count(:user_id)
      @average_score = @attempts.average(:score).to_f.round(1)
      @average_percentage = @question_count.positive? ? ((@average_score / @question_count) * 100).round : 0

      filtered_responses = QuizResponse.where(quiz_attempt_id: @report_attempts.select(:id))
      @question_stats = @module.questions.published
        .joins("LEFT JOIN (#{filtered_responses.to_sql}) report_responses ON report_responses.question_id = questions.id")
        .select("questions.*, COUNT(report_responses.id) AS responses_count, COALESCE(SUM(CASE WHEN report_responses.correct THEN 1 ELSE 0 END), 0) AS correct_responses_count")
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
      if @module.destroy
        redirect_to teacher_quiz_modules_path(locale: I18n.locale), notice: t("teacher.module_deleted")
      else
        redirect_to teacher_quiz_module_path(@module, locale: I18n.locale), alert: @module.errors.full_messages.to_sentence
      end
    end

    private

    def set_module
      @module = current_user.authored_quiz_modules.where(platform_default: false).find(params[:id])
    end

    def module_params
      params.require(:quiz_module).permit(:title_pt, :title_en, :slug, :position, :unlocked, :published, :audience)
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
