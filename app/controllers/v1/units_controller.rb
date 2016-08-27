class V1::UnitsController < ApplicationController

  before_action :allow_if_lecturer, only: [:create]
  before_action :set_unit, only: [:show, :update, :destroy]


  def index
    @units = Unit.all
    render json: @units, status: :ok
  end

  def show
    render json: @unit
  end

  def create
    @unit = Unit.new(unit_params)

    if @unit.save
      render json: @unit, status: :created
    else
      render json: format_errors(@unit.errors), status: :unprocessable_entity
    end
  end

  def update
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

    def allow_if_owner
    end

    def set_unit
      @unit = Unit.find(unit_params[:id])
    end

    def unit_params
      params.permit(:id, :name, :code, :semester, :year, :archived_at, :lecturer_id, :department_id,
        department_attributes: [:name, :university])
    end
end
