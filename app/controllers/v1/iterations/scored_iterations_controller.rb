class V1::Iterations::ScoredIterationsController < ApplicationController
  # GET /scored-iterations
  def index
    iterations = current_user.scored_iterations
    if iterations.length > 0
      render json: current_user.scored_iterations, status: :ok
    else
      render json: [], status: :no_content
    end
  end
end
