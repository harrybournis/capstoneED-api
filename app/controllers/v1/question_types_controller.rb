# Controller for all possible question types
class V1::QuestionTypesController < ApplicationController
  # GET /question_types
  def index
    render json: QuestionType.all, status: :ok
  end
end
