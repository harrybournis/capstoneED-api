class V1::Logs::StatsController < ApplicationController

  before_action :allow_if_lecturer, only: :hours_worked
  before_action :contains_project_id, only: :hours_worked
  before_action :set_project_if_associated, only: :hours_worked

  # GET /stats?graph=hours_worked&project_id=2
  def hours_worked
    result = []

    @project.students_projects.eager_load(:student).each do |sp|
      student_logs = { name: sp.student.full_name, data: [], visible: false }

      sp.logs.each do |log|
        # Time.at(log['date_worked'].to_i).to_datetime
        #
        student_logs[:data] << [log['date_worked'].to_i * 1000, log['time_worked'].to_i / 3600]
      end
      result << student_logs
    end

    render json: { hours_worked_graph: result }.to_json, status: :ok
  end

  private

  def contains_project_id
    unless params[:project_id]
      render json: format_errors(base: ["The graph 'hours_worked' needs a project_id in the params"]), status: :bad_request
      return
    end
  end

  def set_project_if_associated
    unless @project = current_user.projects(includes: includes_array).where(id: params[:project_id])[0]
      render_not_associated_with_current_user('Project')
      false
    end
  end

  def format_date date
    "Date.UTC(#{date.year}, #{date.month - 1}, #{date.day})".to_json
  end

end
