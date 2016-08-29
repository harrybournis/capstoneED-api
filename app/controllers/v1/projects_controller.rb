class V1::ProjectsController < ApplicationController

  before_action :allow_if_lecturer,     only: [:create, :update, :destroy]
  before_action :set_unit_if_owner,     only: [:index], if: 'project_params[:unit_id]'
  before_action :set_project_if_owner,  only: [:show, :update, :destroy]

  # GET /projects
  def index
    render json: @unit ? @unit.projects : current_user.load.projects, status: :ok
  end

  # GET /projects/1
  def show
    render json: @project, status: :ok
  end

  # POST /projects
  def create
    @project = Project.new(project_params)
    @project.lecturer_id = current_user.id

    if @project.save
      render json: @project, status: :created
    else
      render json: format_errors(@project.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      render json: @project
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # DELETE /projects/1
  def destroy
    if @project.destroy
      render json: '', status: :no_content
    else
      render json: format_errors(@project.errors), status: :unprocessable_entity
    end
  end

  private

    def set_unit_if_owner
      @unit = Unit.find_by(id: project_params[:unit_id])
      unless current_user.load.units.include? @unit
        render json: format_errors({ base: ["This Unit can not be found in the current user's Units"] }), status: :forbidden
      end
    end

    def set_project_if_owner
      @project = Project.find_by(id: project_params[:id])
      unless current_user.projects.include? @project
        render json: format_errors({ base: ["This Project can not be found in the current user's Projects"] }), status: :forbidden
      end
    end

    def project_params
      params.permit(:id, :start_date, :end_date, :description, :unit_id)
    end
end
