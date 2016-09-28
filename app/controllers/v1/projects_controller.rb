class V1::ProjectsController < ApplicationController

  before_action :allow_if_lecturer, only: [:index_with_unit, :create, :update, :destroy]
  before_action :validate_includes, only: [:index, :index_with_unit, :show], if: 'params[:includes]'
  before_action :delete_includes_from_params, only: [:update, :destroy]
  before_action :set_project_if_associated, only: [:show, :update, :destroy]


  # GET /projects
  def index
    serialize_collection current_user.projects(includes: includes_array), :ok
  end

  # GET /projects?unit_id=4
  # Only Lecturers
  # Get the projects of the specified unit_id. Unit must belong to Lecturer.
  def index_with_unit
    if (@projects = current_user.projects(includes: params[:includes]).where(unit_id: params[:unit_id])).empty?
      render_not_associated_with_current_user('Unit')
      return false
    end
    serialize_collection @projects, :ok
  end

  # GET /projects/:id
  def show
    serialize_object @project, :ok
  end

  # POST /projects
  # Only Lecturers
  def create
    @project = Project.new(project_params.merge(lecturer_id: current_user.id))

    if @project.save
      if params[:teams_attributes]
        render json: @project, serializer: Includes::ProjectSerializer, include: 'teams', status: :created
      else
        render json: @project, status: :created
      end
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

    # Sets @project if it is asociated with the current user. Eager loads associations in the params[:includes].
    # Renders error if not associated and Halts execution
    def set_project_if_associated
      unless @project = current_user.projects(includes: includes_array).where(id: params[:id])[0]
        render_not_associated_with_current_user('Project')
        return false
      end
    end

    # The class of the resource that the controller handles
    def controller_resource
      Project
    end

    def project_params
      params.permit(:id, :start_date, :end_date, :description, :unit_id,
        teams_attributes: [:name, :enrollment_key, :logo])
    end
end
