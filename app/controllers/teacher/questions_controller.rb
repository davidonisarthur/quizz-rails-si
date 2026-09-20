module Teacher
  class QuestionsController < BaseController
    before_action :set_module
    before_action :set_question, only: %i[edit update destroy duplicate move]

    def new
      @question = @module.questions.build(published: false, correct_index: 0, position: next_question_position)
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

    def duplicate
      copy = nil

      Question.transaction do
        @module.lock!
        source = @module.questions.lock.find(@question.id)
        copy = source.dup
        copy.assign_attributes(published: false, position: next_question_position)
        copy.save!
        source.options.order(:id).each { |option| copy.options.create!(text_pt: option.text_pt, text_en: option.text_en) }
        source.feedbacks.order(:kind).each { |feedback| copy.feedbacks.create!(kind: feedback.kind, body_pt: feedback.body_pt, body_en: feedback.body_en) }
      end

      redirect_to edit_teacher_quiz_module_question_path(@module, copy, locale: I18n.locale), notice: t("teacher.question_duplicated")
    end

    def move
      direction = params[:direction].to_s
      moved = false

      Question.transaction do
        @module.lock!
        question = @module.questions.lock.find(@question.id)
        neighbour = adjacent_question(question, direction)
        next unless neighbour

        neighbour.lock!

        current_position = question.position
        neighbour_position = neighbour.position
        temporary_position = @module.questions.maximum(:position).to_i + 1
        question.update_column(:position, temporary_position)
        neighbour.update_column(:position, current_position)
        question.update_column(:position, neighbour_position)
        moved = true
      end

      redirect_to teacher_quiz_module_path(@module, locale: I18n.locale), notice: moved ? t("teacher.question_moved") : nil
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

    def next_question_position
      @module.questions.maximum(:position).to_i + 1
    end

    def adjacent_question(question, direction)
      case direction
      when "up"
        @module.questions.where("position < ?", question.position).order(position: :desc).first
      when "down"
        @module.questions.where("position > ?", question.position).order(:position).first
      end
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
