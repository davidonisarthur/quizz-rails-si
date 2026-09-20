module Teacher
  class QuestionsController < BaseController
    before_action :set_module
    before_action :set_question, only: %i[edit update destroy]

    def new
      @question = @module.questions.build(published: false, correct_index: 0)
      build_question_details
    end

    def create
      @question = @module.questions.build(question_params)
      build_question_details
      save_question
    end

    def edit
      build_question_details
    end

    def update
      @question.assign_attributes(question_params)
      build_question_details
      save_question
    end

    def destroy
      @question.destroy
      redirect_to teacher_quiz_module_path(@module, locale: I18n.locale), notice: t("teacher.question_deleted")
    end

    private

    def set_module
      @module = current_user.authored_quiz_modules.find(params[:quiz_module_id])
    end

    def set_question
      @question = @module.questions.find(params[:id])
    end

    def question_params
      params.require(:question).permit(
        :body_pt, :body_en, :context_pt, :context_en, :libras_video_url, :correct_index, :published,
        options_attributes: %i[id text_pt text_en],
        feedbacks_attributes: %i[id kind body_pt body_en]
      )
    end

    def build_question_details
      (4 - @question.options.size).times { @question.options.build }
      %w[correct incorrect].each do |kind|
        @question.feedbacks.build(kind: kind) unless @question.feedbacks.any? { |feedback| feedback.kind == kind }
      end
    end

    def save_question
      if @question.published? && !@question.ready_to_publish?
        @question.errors.add(:published, t("teacher.question_not_ready"))
        render action_name == "create" ? :new : :edit, status: :unprocessable_entity
      elsif @question.save
        redirect_to teacher_quiz_module_path(@module, locale: I18n.locale), notice: t("teacher.question_saved")
      else
        render action_name == "create" ? :new : :edit, status: :unprocessable_entity
      end
    end
  end
end
