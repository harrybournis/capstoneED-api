## Assignments Controller
class V1::AssignmentsController < ApplicationController
  before_action :allow_if_lecturer,
                only: [:index_with_unit, :create, :update, :destroy]
  before_action :validate_includes,
                only: [:index, :index_with_unit, :show],
                if: 'params[:includes]'
  before_action :delete_includes_from_params, only: [:update, :destroy]
  before_action :set_assignment_if_associated, only: [:show, :update, :destroy]

  # GET /assignments
  def index
    serialize_collection current_user.assignments(includes: includes_array), :ok
  end

  # GET /assignments?unit_id=4
  # Only Lecturers
  # Get the assignments of the specified unit_id. Unit must belong to Lecturer.
  def index_with_unit
    @assignments = current_user.assignments(includes: params[:includes])
                               .where(unit_id: params[:unit_id])
    serialize_collection @assignments, :ok
  end

  # GET /assignments/:id
  def show
    serialize_object @assignment, :ok
  end

  # POST /assignments
  # Only Lecturers
  def create
    @assignment = Assignment.new(assignment_params.merge(lecturer_id: current_user.id))

    if @assignment.save
      if params[:projects_attributes]
        render json: @assignment,
               serializer: Includes::AssignmentSerializer,
               include: 'projects',
               status: :created
      else
        render json: @assignment, status: :created
      end
    else
      render json: format_errors(@assignment.errors),
             status: :unprocessable_entity
    end
  end

  # PATCH /assignments/:id
  # Only Lecturers
  def update
    if @assignment.update(assignment_params)
      render json: @assignment, status: :ok
    else
      render json: @assignment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /assignments/:id
  # Only Lecturers
  def destroy
    if @assignment.destroy
      render json: '', status: :no_content
    else
      render json: format_errors(@assignment.errors),
             status: :unprocessable_entity
    end
  end

  private

  # Sets @assignment if it is asociated with the current user. Eager loads
  # associations in the params[:includes]. Renders error if not associated
  # and Halts execution.
  def set_assignment_if_associated
    unless @assignment = current_user.assignments(includes: includes_array)
                                     .where(id: params[:id])[0]
      render_not_associated_with_current_user('Assignment')
      false
    end
  end

  # The class of the resource that the controller handles
  def controller_resource
    Assignment
  end

  def assignment_params
    params.permit(:name, :start_date, :end_date, :unit_id,
      projects_attributes: [:project_name,
                            :team_name,
                            :description,
                            :enrollment_key,
                            :logo])
  end
end
