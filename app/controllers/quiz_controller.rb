class QuizController < ApplicationController
  before_action :set_module

  def show
    questions = @module.questions.order(:id)

    if params[:question_index].present? && session[:quiz].present? && session[:quiz]["module_id"] == @module.id
      session[:quiz]["question_index"] = params[:question_index].to_i
    else
      session[:quiz] = { "module_id" => @module.id, "question_index" => 0, "score" => 0 }
    end

    @question = questions[session[:quiz]["question_index"]]

    if @question.nil?
      redirect_to result_quiz_module_path(@module.slug, locale: I18n.locale)
    else
      @options = @question.options.order(:id)
    end
  end

  def answer
    quiz      = session[:quiz]
    questions = @module.questions.order(:id)
    @question = questions[quiz["question_index"]]
    chosen    = params[:option_index].to_i
    correct   = chosen == @question.correct_index
    session[:quiz]["score"] += 1 if correct
    @feedback = @question.feedbacks.find_by(kind: correct ? "correct" : "incorrect")
    @next_index = quiz["question_index"] + 1
    session[:quiz]["question_index"] = @next_index
    @next_question = questions[@next_index]
    @options = @question.options.order(:id)
    render :answer
  end

  def result
    score = session.dig(:quiz, "score") || 0
    total = @module.questions.count
    if current_user
      QuizAttempt.create(user: current_user, quiz_module: @module, score: score)
    end
    @score = score
    @total = total
    session.delete(:quiz)
  end

  private

  def set_module
    @module = QuizModule.find_by!(slug: params[:slug])
  end
end
