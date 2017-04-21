## Questions Controller
class V1::QuestionsController < ApplicationController
  before_action :allow_if_lecturer
  before_action :delete_includes_from_params
  before_action :set_question_if_associated, only: [:show, :update, :destroy]

  # GET /custom_questions
  def index
    render json: current_user.questions, status: :ok
  end

  # GET /custom_questions/:id
  def show
    render json: @question, status: :ok
  end

  # POST /questions
  def create
    @question = Question.new(question_params)
    @question.lecturer = current_user.load

    if @question.save
      render json: @question, status: :created
    else
      render json: format_errors(@question.errors),
             status: :unprocessable_entity
    end
  end

  # PATCH /questions/:id
  def update
    if @question.update(question_params)
      render json: @question, status: :ok
    else
      render json: format_errors(@question.errors),
             status: :unprocessable_entity
    end
  end

  def destroy
    if @question.destroy
      render json: '', status: :no_content
    else
      render json: format_errors(@question.errors),
             status: :unprocessable_entity
    end
  end

  private

  # Sets @question if it is asociated with the current user.
  # Eager loads associations in the params[:includes].
  # Renders error if not associated and Halts execution
  def set_question_if_associated
    unless @question = current_user.questions.where(id: params[:id])[0]
      render_not_associated_with_current_user('Question')
      return false
    end
  end

  # The class of the resource that the controller handles
  def controller_resource
    Question
  end

  def question_params
    params.permit(:question_type_id, :text)
  end
end
