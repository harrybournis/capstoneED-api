class V1::ProjectsController < ApplicationController

  before_action :allow_if_lecturer,     only: [:create, :update, :destroy]
  before_action -> {
    set_if_owner(Unit, params[:unit_id], '@unit') }, only: [:index], if: 'params[:unit_id]'
  before_action -> {
   set_if_owner(Project, params[:id], '@project') }, only: [:show, :update, :destroy]

  # GET /projects
  def index
    serialize_collection_params @unit ? @unit.projects : current_user.load.projects, :ok
  end

  # GET /projects/:id
  def show
    serialize_params @project, :ok
  end

  # POST /projects
  # Only Lecturers
  def create
    @project = Project.new(project_params)
    @project.lecturer_id = current_user.id

    if @project.save
      render json: @project, status: :created
    else
      render json: format_errors(@project.errors), status: :unprocessable_entity
    end
  end

  # PATCH /projects/:id
  # Only Lecturers
  def update
    if @project.update(project_params)
      render json: @project, status: :ok
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:id
  # Only Lecturers
  def destroy
    if @project.destroy
      render json: '', status: :no_content
    else
      render json: format_errors(@project.errors), status: :unprocessable_entity
    end
  end


  private

    def project_params
      params.permit(:id, :start_date, :end_date, :description, :unit_id)
    end
end
