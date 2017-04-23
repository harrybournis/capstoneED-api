class V1::PointsController < ApplicationController

  before_action :set_project_if_associated, only: :index_for_project
  before_action :set_assignment_if_associated, only: :index_for_assignment

  # GET /v1/projects/:project_id/points
  def index_for_project
    render json: index_for_project_response, status: :ok
  end

  # GET /v1/assignments/:assignment_id/points
  def index_for_assignment
    render json: index_for_assignment_response, status: :ok
  end

  private

  def index_for_project_response
    json =  { points: {
                        average: @project.team_average,
                        total: @project.team_points
                      }
            }
    json[:points][:personal] = current_user.points_for_project_id(@project.id) if current_user.student?
    json
  end

  def index_for_assignment_response
    projects = []

    if current_user.student?
      my_project_id = current_user.projects.where(assignment_id: @assignment.id)[0].id
    end

    @assignment.projects.each do |project|
      project_hash =  {
                        project_id: project.id,
                        team_name: project.team_name,
                        total: project.team_points,
                        average: project.team_average
                      }
      if my_project_id && my_project_id == project.id
        project_hash[:my_team] = true
        project_hash[:personal] = current_user.load.points_for_project_id(my_project_id)
      end
      projects << project_hash
    end

    json = { points: projects }
    json
  end

  def set_project_if_associated
    found = false
    if current_user.student?
      @project = Project.eager_load(:students_projects).where(id: params[:project_id])[0]


      @project.students_projects.each { |sp| found = true if sp.student_id == current_user.id }
    else
      if @project = current_user.projects.where(id: params[:project_id])[0]
        found = true
      end
    end

    unless found
      render_not_associated_with_current_user('Project')
      false
    end
  end

  def set_assignment_if_associated
    unless @assignment = current_user.assignments
                                     .where(id: params[:assignment_id])[0]
      render_not_associated_with_current_user('Assignment')
      false
    end
  end
end
