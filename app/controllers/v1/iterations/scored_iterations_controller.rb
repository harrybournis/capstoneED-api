class V1::Iterations::ScoredIterationsController < ApplicationController
  before_action :allow_if_lecturer, only: :show
  before_action :set_iteration_if_association, only: :show

  # GET /scored-iterations
  def index
    iterations = current_user.scored_iterations
    if iterations.length > 0
      render json: current_user.scored_iterations, status: :ok
    else
      render json: [], status: :no_content
    end
  end

  # GET /scored-iterations/:id
  def show
    render json: @iteration.projects, each_serializer: ScoredProjectSerializer, iteration: @iteration, status: :ok
  end

  private

  def set_iteration_if_association
    unless @iteration = current_user.scored_iterations.where(id: params[:id])[0]
      render_not_associated_with_current_user('Scored Iteration')
      false
    end
  end
end
