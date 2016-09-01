class V1::UnitsController < ApplicationController

  before_action :allow_if_lecturer, only: [:index ,:create]
  before_action -> { set_if_owner(Unit, params[:id], '@unit') },    only: [:show, :update, :destroy]


  def index
    render json: current_user.load.units, status: :ok
  end


  def show
    render json: @unit, status: :ok
  end


  def create
    params.delete(:department_attributes) if unit_params[:department_id]

    @unit = Unit.new(unit_params)

    if current_user.load.units << @unit
      render json: @unit, status: :created
    else
      render json: format_errors(@unit.errors), status: :unprocessable_entity
    end
  end


  def update
    params.delete(:department_attributes) if unit_params[:department_id]

    if @unit.update(unit_params)
      render json: @unit, status: :ok
    else
      render json: format_errors(@unit.errors), status: :unprocessable_entity
    end
  end


  def destroy
    if @unit.destroy
      render json: '', status: :no_content
    else
      render json: format_errors(@unit.errors), status: :unprocessable_entity
    end
  end


  private

    def unit_params
      params.permit(:id, :name, :code, :semester, :year, :archived_at, :department_id,
        department_attributes: [:name, :university])
    end
end
