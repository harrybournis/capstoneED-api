class V1::ProjectEvaluations::StatsController < ApplicationController
  before_action :allow_if_lecturer, only: :percent_completion
  before_action :contains_project_id, only: :percent_completion
  before_action :set_project_if_associated,  only: :percent_completion

  # GET /stats?graph=percent_completion&project_id=2
  def percent_completion
    @students_hash = Hash.new { |key,val| key[val] = Hash.new { |k,v| k[v] = [] } }
    @lecturer_hash = Hash.new { |key,val| key[val] = Hash.new { |k,v| k[v] = [] } }

    @project.iterations.each do |iteration|
      next unless iteration.finished?

      iteration.project_evaluations.order(:date_submitted).each do |pe|
        h = pe.user.lecturer? ? @lecturer_hash : @students_hash
        time_period = ''

        if calculate_progress(pe.date_submitted.to_i, iteration.start_date.to_i, iteration.deadline.to_i).between?(0.4, 0.5)
          time_period = ' - 1st Half'
        end

        h[iteration.id][iteration.name + time_period] << pe.percent_complete
      end
    end

    results = []
    @lecturer_results = { name: "Lecturer's Estimation" , data: [] }
    @lecturer_hash.each do |iteration_id,value|
      value.each do |name,percent|
        @lecturer_results[:data] << [name,percent[0]]
      end
    end

    @students_results = { name: "Students' Average Estimation", data: [] }
    @students_hash.each do |iteration_id,value|
      value.each do |name,percent|
        @students_results[:data] << [name,percent.inject(:+).to_f / percent.length]
      end
    end

    render json: { percent_completion_graph: [@lecturer_results,@students_results] }.to_json, status: :ok
  end

  private

  def contains_project_id
    unless params[:project_id]
      render json: format_errors(base: ["The graph 'project_completion' needs a project_id in the params"]), status: :bad_request
      return
    end
  end

  def set_project_if_associated
    unless @project = current_user.projects(includes: [:iterations, :students, :lecturer]).where(id: params[:project_id])[0]
      render_not_associated_with_current_user('Project')
      false
    end
  end
end
