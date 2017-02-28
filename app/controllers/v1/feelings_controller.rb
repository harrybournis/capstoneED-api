## Feelings Controller
class V1::FeelingsController < ApplicationController
  # GET /feelings
  def index
    render json: Feeling.all, status: :ok
  end
end
