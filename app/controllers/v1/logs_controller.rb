class V1::LogsController < ApplicationController
  before_action :allow_if_student,
                only: [:update, :index_student]
  before_action :allow_if_lecturer,
                only: [:index_lecturer]
  before_action :set_project_if_associated,
                only: [:index_lecturer]
  before_action :set_students_project_if_associated,
                only: [:update, :index_student]

  # GET /projects/:id/logs
  # Only for Student
  def index_student
    render json: { logs: @students_project.logs }, status: :ok
  end

  # GET /projects/:id/logs
  # Only for lecturer
  # Needs student_id in params
  def index_lecturer
    unless @students_project = JoinTables::StudentsProject.where(student_id: params[:student_id], project_id: params[:id])[0]
      render json: format_errors({ student_id: ['does not belong to this project'] }),
             status: :unprocessable_entity
      return
    end

    render json: { logs: @students_project.logs }, status: :ok
  end

  # POST /projects/:id/logs
  # Only for Student
  def update
    @log = Log.new log_params.to_h.to_h, @students_project

    if @log.save
      @points_board = award_points :log, @log

      if @points_board.success?
        render json: serialize_w_points(@log, @points_board),
               status: :created
      else
        render json: serialize_w_points(
                        @log, @points_board),
               status: :created
      end
    else
      render json: format_errors(@log.errors),
             status: :unprocessable_entity
    end
  end

  private

  # Sets @project if it is asociated with the current user.
  # Eager loads associations in the params[:includes].
  # Renders error if not associated and Halts execution
  def set_project_if_associated
    unless @project = current_user.projects(includes: includes_array)
                                  .where(id: params[:id])[0]
      render_not_associated_with_current_user('Project')
      false
    end
  end

  # Sets @project if it is asociated with the current user.
  # Eager loads associations in the params[:includes].
  # Renders error if not associated and Halts execution
  def set_students_project_if_associated
    unless @students_project = JoinTables::StudentsProject.where(student_id: current_user.id, project_id: params[:id])[0]
      render_not_associated_with_current_user('Project')
      false
    end
  end

  def log_params
    params.permit(:date_worked, :time_worked, :stage, :text)
  end
end
