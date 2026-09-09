class QuizController < ApplicationController
  before_action :set_module

  def show
    questions = @module.questions.order(:id)

    if session[:quiz].present? && session[:quiz]["module_id"] == @module.id
      if params[:question_index].present?
        session[:quiz]["question_index"] = params[:question_index].to_i
      end
    else
      session[:quiz] = { "module_id" => @module.id, "question_index" => 0, "score" => 0 }
      session.delete(:last_attempt_id)
      session.delete(:last_score)
    end

    @current_index = session[:quiz]["question_index"]
    @total_questions = questions.count
    @question = questions[@current_index]

    if @question.nil?
      redirect_to result_quiz_module_path(@module.slug, locale: I18n.locale)
    else
      @options = @question.options.order(:id)
    end
  end

  def answer
    if session[:quiz].blank? || session[:quiz]["module_id"] != @module.id
      redirect_to play_quiz_module_path(@module.slug, locale: I18n.locale) and return
    end

    quiz      = session[:quiz]
    questions = @module.questions.order(:id)
    @current_index = quiz["question_index"]
    @total_questions = questions.count
    @question = questions[@current_index]

    if @question.nil?
      redirect_to play_quiz_module_path(@module.slug, locale: I18n.locale) and return
    elsif params[:question_id].blank? || @question.id != params[:question_id].to_i
      redirect_to play_quiz_module_path(@module.slug, locale: I18n.locale, question_index: @current_index) and return
    end

    chosen    = params[:option_index].to_i
    correct   = chosen == @question.correct_index
    session[:quiz]["score"] += 1 if correct
    @feedback = @question.feedbacks.find_by(kind: correct ? "correct" : "incorrect")
    @feedback ||= Feedback.new(
      body_pt: "Sem feedback cadastrado.",
      body_en: "No feedback registered.",
      kind: correct ? "correct" : "incorrect"
    )

    @next_index = @current_index + 1
    session[:quiz]["question_index"] = @next_index
    @next_question = questions[@next_index]

    if @next_question.nil?
      score = session[:quiz]["score"]
      if current_user
        attempt = QuizAttempt.create!(user: current_user, quiz_module: @module, score: score)
        session[:last_attempt_id] = attempt.id
      else
        session[:last_score] = { "score" => score, "total" => @total_questions }
      end
      session.delete(:quiz)
    end

    @options = @question.options.order(:id)
    render :answer
  end

  def result
    if current_user
      attempt = current_user.quiz_attempts.find_by(id: session[:last_attempt_id]) ||
                current_user.quiz_attempts.where(quiz_module: @module).last
      if attempt
        @score = attempt.score
        @total = @module.questions.count
      else
        redirect_to play_quiz_module_path(@module.slug, locale: I18n.locale) and return
      end
    else
      last_score = session[:last_score]
      if last_score
        @score = last_score["score"]
        @total = last_score["total"]
      else
        redirect_to play_quiz_module_path(@module.slug, locale: I18n.locale) and return
      end
    end
  end

  private

  def set_module
    @module = QuizModule.find_by!(slug: params[:slug])
  end
end
