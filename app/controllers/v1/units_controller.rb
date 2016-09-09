class V1::UnitsController < ApplicationController

  before_action :allow_if_lecturer, only: [:index ,:create]
  #before_action -> { set_if_owner(Unit, params[:id], '@unit') },    only: [:show, :update, :destroy]
  before_action -> {
    validate_includes(current_user.unit_associations, includes_array, 'Unit')
  }, only: [:index, :show], if: 'params[:includes]'

  before_action :delete_includes_from_params, only: [:update, :destroy]
  before_action :set_unit_if_associated,      only: [:show, :update, :destroy]

  # GET /units
  # Only for Lecturers
  def index
    serialize_collection_params current_user.units(includes: includes_array), :ok
  end

  # GET /units/:id
  def show
    serialize_params @unit, :ok
  end

  # POST /units
  # If department_id is present, it is assotiated with the Unit
  # If department_attributes, the department is created
  def create
    params.delete(:department_attributes) if unit_params[:department_id]

    @unit = Unit.new(unit_params)

    if current_user.load.units << @unit
      render json: @unit, status: :created
    else
      render json: format_errors(@unit.errors), status: :unprocessable_entity
    end
  end

  # PATCH /units/:id
  # If department_id is present, it is assotiated with the Unit
  # If department_attributes, the department is created
  def update
    params.delete(:department_attributes) if unit_params[:department_id]

    if @unit.update(unit_params)
      render json: @unit, status: :ok
    else
      render json: format_errors(@unit.errors), status: :unprocessable_entity
    end
  end

  # DELETE /units/:id
  def destroy
    if @unit.destroy
      render json: '', status: :no_content
    else
      render json: format_errors(@unit.errors), status: :unprocessable_entity
    end
  end


  private

    def set_unit_if_associated
      unless @unit = current_user.units(includes: includes_array).where(id: params[:id])[0]
        render_not_associated_with_current_user('Unit')
        return false
      end
    end

    def controller_resource
      Unit
    end

    def unit_params
      params.permit(:id, :name, :code, :semester, :year, :archived_at, :department_id,
        department_attributes: [:name, :university])
    end
end
