# Controller for stats and graphs
class V1::Logs::StatsController < ApplicationController
  #before_action :allow_if_lecturer, only: [:hours_worked_project, :hours_worked_assignment]
  before_action :contains_project_id, only: [:hours_worked_project, :logs_heatmap]
  before_action :contains_assignment_id, only: :hours_worked_assignment
  before_action :set_project_if_associated,  only: [:hours_worked_project, :logs_heatmap]
  before_action :set_assignment_if_associated,  only: :hours_worked_assignment

  # GET /stats?graph=hours_worked&project_id=2
  def hours_worked_project
    result = []

    average_hash = Hash.new { |key,val| key[val] = [] }

    @project.students_projects.eager_load(:student).each do |sp|
      student_logs = { name: sp.student.full_name, data: [], visible: false }

      sp.logs.each do |log|
        date = Time.at(log['date_worked'].to_i).beginning_of_day.to_i * 1000
        time = log['time_worked'].to_i / 3600

        average_hash[date] << time
        student_logs[:data] << [date, time]
      end
      result << student_logs
    end

    average_result = { name: 'Team Average', data: [] }
    average_hash.keys.sort.each do |date_worked|
      time_array = average_hash[date_worked]
      average_result[:data] << [date_worked, (time_array.inject(:+).to_f / time_array.length).round(1)]
    end

    result.unshift average_result

    render json: { hours_worked_graph: result }.to_json, status: :ok
  end

  # GET /stats?graph=hours_worked&assignment_id=2
  def hours_worked_assignment
    result = []

    average_hash = Hash.new { |key,val| key[val] = Hash.new { |key,val| key[val] = [] } }

    @assignment.students_projects.eager_load(:student, :project).each do |sp|
      sp.logs.each do |log|
        date = Time.at(log['date_worked'].to_i).beginning_of_day.to_i * 1000
        time = log['time_worked'].to_i / 3600

        average_hash[sp.project.project_name][date] << time
      end
    end

    average_hash.each do |project_name,date_time|
      team_result = { name: project_name, data: [] }
      #binding.pry
      date_time.keys.sort.each do |date|
        time = date_time[date]
        team_result[:data] << [date, (time.inject(:+).to_f / time.length).round(1)]
      end
      result << team_result
    end

    render json: { hours_worked_graph: result }.to_json, status: :ok
  end

  # GET /stats?graph=logs_heatmap
  def logs_heatmap
    result = []
    logs_count_hash = Hash.new { |key,val| key[val] = Hash.new { |key,val| key[val] = Hash.new { |key,val| key[val] = 0 } } }

    order_hash = {}
    @project.students_projects.order(:id).eager_load(:student).each_with_index do |sp,index|
      #logs_count_hash[sp.student_id][sp.student.full_name] = 0
      order_hash[sp.student_id] = index
      sp.logs.each do |log|
        date = Time.at(log['date_submitted'].to_i).beginning_of_day.to_i * 1000

        if logs_count_hash[sp.student_id][sp.student.full_name][date]
          logs_count_hash[sp.student_id][sp.student.full_name][date] += 1
        else
          average_hash[sp.student_id][sp.student.full_name][date] = 1
        end
      end
    end

    logs_count_hash.each do |student_id,name_date|
      name_date.each do |name,date_number|
        student =  { name: name, data: [] }
        date_number.keys.sort.each do |date|
          number_of_logs = date_number[date]
          student[:data] << [date, order_hash[student_id], number_of_logs]
        end
        # date_number.each do |date,number_of_logs|
        #   student[:data] << [date, order_hash[student_id], number_of_logs]
        # end
        result << student
      end
    end

    render json: { logs_heatmap: result }.to_json, status: :ok
  end

  private

  # Before action that checks if params include project_id
  def contains_project_id
    unless params[:project_id]
      render json: format_errors(base: ["The graph 'hours_worked' needs a project_id or assignment_id in the params"]), status: :bad_request
      return
    end
  end

  # Before action that checks if params include assignment_id
  def contains_assignment_id
    unless params[:assignment_id]
      render json: format_errors(base: ["The graph 'hours_worked' needs a project_id or assignment_id in the params"]), status: :bad_request
      return
    end
  end

  # Sets @project if the project_id belongs to a project assiciated with
  # the current user.
  def set_project_if_associated
    unless @project = current_user.projects(includes: [:students_projects, :students]).where(id: params[:project_id])[0]
      render_not_associated_with_current_user('Project')
      false
    end
  end

  # Sets @assgnment if the assgnment_id belongs to a assignemnt assiciated
  # with the current user.
  def set_assignment_if_associated
    unless @assignment = current_user.assignments.where(id: params[:assignment_id])[0]
      render_not_associated_with_current_user('Assignment')
      false
    end
  end

  # Returns a string of a javascript method that parses date to utc.
  def format_date date
    "Date.UTC(#{date.year}, #{date.month - 1}, #{date.day})".to_json
  end

end
