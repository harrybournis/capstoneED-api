## Iterations Controller
class V1::IterationsController < ApplicationController
  before_action :allow_if_lecturer, only: :create
  before_action :validate_includes,
                only: [:index, :show],
                if: 'params[:includes]'
  before_action :set_iteration_if_associated,
                only: [:show, :update, :destroy]

  # GET /iterations?project_id=
  # Needs project_id in params
  def index
    unless params[:assignment_id]
      render json: format_errors({ base: ['This Endpoint requires a assignment_id in the params'] }),
             status: :bad_request
      return
    end

    @iterations = current_user.iterations(includes: params[:includes])
                              .where(assignment_id: params[:assignment_id])
    serialize_collection @iterations, :ok
  end

  # GET /iterations/:id
  def show
    serialize_object @iteration, :ok
  end

  # POST /iterations
  # Only for Lecturers
  def create
    unless current_user.assignments.find_by(id: params[:assignment_id])
      render json: format_errors({ assignment_id: ["is not one of current user's assignments"] }),
             status: :forbidden
      return
    end

    @iteration = Iteration.create(iteration_params)

    if @iteration.save
      render json: @iteration, status: :created
    else
      render json: format_errors(@iteration.errors),
             status: :unprocessable_entity
    end
  end

  # PATCH /iterations/:id
  def update
    if @iteration.update(iteration_update_params)
      render json: @iteration, status: :ok
    else
      render json: @iteration.errors, status: :ok
    end
  end

  # DELETE /iterations/:id
  def destroy
    @iteration.destroy
    render json: '', status: :no_content
  end

  private

  # Sets @iteration if it is asociated with the current user.
  # Eager loads associations in the params[:includes].
  # Renders error if not associated and Halts execution
  def set_iteration_if_associated
    unless @iteration = current_user.iterations(includes: includes_array)
                                    .where(id: params[:id])[0]
      render_not_associated_with_current_user('Iteration')
      return false
    end
  end

  # The class of the resource that the controller handles
  def controller_resource
    Iteration
  end

  def iteration_params
    params.permit(:name, :start_date, :deadline, :assignment_id,
                  pa_form_attributes: [:start_offset,
                                       :end_offset,
                                       questions: []])
  end

  def iteration_update_params
    params.permit(:name, :start_date, :deadline)
  end
end
