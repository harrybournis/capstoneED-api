class V1::PredefinedQuestions < ApplicationController

	before_action :allow_if_lecturer

	def index
		render json: PredefinedQuestion.all, status: :ok
	end

	def show
		render json: @predefined_question, status: :ok
	end


	private

		def set_predefined_question
			@predefined_question = PredefinedQuestion.find(params[:id])
		end
end
