# Project Evaluation Controller
class V1::ProjectEvaluationsController < ApplicationController
  before_action :allow_if_lecturer, only: [:update]
  before_action :set_project_evaluation_if_associated, only: :update
  before_action :set_project_if_associated, only: :index_with_project
  before_action :set_iteration_if_associated, only: :index_with_iteration

  # GET /project/:project_id/evaluations
  def index_with_project
    render json: @project, serializer: ProjectStatsSerializer
  end

  # GET /iteration/:iteration_id/evaluations
  def index_with_iteration
    render json: @iteration, serializer: IterationStatsSerializer
  end

  # GET /project-evaluations
  #
  def index
    pending = []
    current_user.iterations_active.each do |iteration|
      iteration.projects.each do |project|
        if project.pending_evaluation(current_user)
          pending << Decorators::PendingProjectEvaluation.new(iteration, project)
        end
      end
    end

    if pending.any?
      render json: pending, each_serializer: PendingProjectEvaluationSerializer, status: :ok
    else
      render json: '', status: :no_content
    end
  end

  # POST /project_evaluations
  def create
    params[:feelings_project_evaluations_attributes] = params['feelings']
    @pe = ProjectEvaluation.new(project_evaluations_params)
    @pe.user = current_user.load

    if @pe.save
      if current_user.student?
        points_board = award_points(:project_evaluation, @pe)

        if points_board.success?
          render json: serialize_w_points(@pe, points_board),
                 status: :created
        else
          render json: serialize_w_points(
                          @pe, points_board),
                 status: :created
        end

      else
        render json: @pe, status: :created
      end
    else
      render json: format_errors(@pe.errors), status: :unprocessable_entity
    end
  end

  # PATCH /project_evaluations?id=2
  # only for lecturers
  def update
    if @pe.update(update_project_evaluation_params)
      render json: @pe, status: :ok
    else
      render json: format_errors(@pe.errors), status: :unprocessable_entity
    end
  end

  private

  # Sets @pe if it is asociated with the current user.
  def set_project_evaluation_if_associated
    unless @pe = current_user.project_evaluations.where(id: params[:id])[0]
      render_not_associated_with_current_user('Project Evaluation')
      false
    end
  end

  def set_project_if_associated
    unless @project = current_user.projects.where(id: params[:project_id])[0]
      render_not_associated_with_current_user('Project')
      false
    end
  end

  def set_iteration_if_associated
    unless @iteration = current_user.iterations.where(id: params[:iteration_id])[0]
      render_not_associated_with_current_useppir('Iteration')
      false
    end
  end

  # The class of the resource that the controller handles
  def controller_resource
    ProjectEvaluation
  end

  def project_evaluations_params
    params.permit(:project_id, :iteration_id, :percent_complete, feelings_project_evaluations_attributes: [:feeling_id, :percent])
  end

  def update_project_evaluation_params
    params.permit( :percent_complete)
  end
end
