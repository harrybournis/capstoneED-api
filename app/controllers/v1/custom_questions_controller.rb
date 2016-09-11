class V1::CustomQuestionsController < ApplicationController

	before_action :allow_if_lecturer
	before_action :delete_includes_from_params
	before_action :set_custom_question_if_associated, only: [:show, :update, :destroy]


	# GET /custom_questions
	def index
		render json: current_user.custom_questions, status: :ok
	end

	# GET /custom_questions/:id
	def show
		render json: @custom_question, status: :ok
	end

	# POST /custom_questions
	def create
		@custom_question = CustomQuestion.new(custom_question_params)
		@custom_question.lecturer = current_user.load

		if @custom_question.save
			render json: @custom_question, status: :created
		else
			render json: format_errors(@custom_question.errors), status: :unprocessable_entity
		end
	end

	# PATCH /custom_questions/:id
	def update
		if @custom_question.update(custom_question_params)
			render json: @custom_question, status: :ok
		else
			render json: format_errors(@custom_question.errors), status: :unprocessable_entity
		end
	end

	def destroy
		if @custom_question.destroy
			render json: '', status: :no_content
		else
			render json: format_errors(@custom_question.errors), status: :unprocessable_entity
		end
	end


	private

    # Sets @unit if it is asociated with the current user. Eager loads associations in the params[:includes].
    # Renders error if not associated and Halts execution
		def set_custom_question_if_associated
      unless @custom_question = current_user.custom_questions.where(id: params[:id])[0]
        render_not_associated_with_current_user('Custom Question')
        return false
      end
		end

    # The class of the resource that the controller handles
    def controller_resource
      CustomQuestion
    end

    def custom_question_params
    	params.permit(:category, :text)
    end
end
