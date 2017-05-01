require 'rails_helper'

RSpec.describe V1::Logs::StatsController, type: :request do
  before :all do
    now = DateTime.now
    @lecturer = create :lecturer_confirmed
    @unit = create :unit, lecturer: @lecturer
    @assignment = create :assignment, lecturer: @lecturer, unit: @unit, start_date: now - 2.months, end_date: now + 2.months
    @project = create :project, assignment: @assignment
    @iteration1 = create :iteration, assignment: @assignment, start_date: @assignment.start_date, deadline: now - 1.months
    @iteration2 = create :iteration, assignment: @assignment ,start_date: now - 1.months, deadline: now - 1.day

    @student1 = create :student_confirmed
    @student2 = create :student_confirmed
    create :students_project, student: @student1, project: @project
    create :students_project, student: @student2, project: @project

    Timecop.travel @iteration1.start_date + ((@iteration1.deadline - @iteration1.start_date) / 2) do
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration1.id, user_id: @student1.id, percent_complete: 30
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration1.id, user_id: @student2.id, percent_complete: 60
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration1.id, user_id: @lecturer.id, percent_complete: 20
    end

    Timecop.travel @iteration1.deadline - 1.hour do
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration1.id, user_id: @student1.id, percent_complete: 20
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration1.id, user_id: @student2.id, percent_complete: 70
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration1.id, user_id: @lecturer.id, percent_complete: 30
    end

    Timecop.travel @iteration2.start_date + ((@iteration2.deadline - @iteration2.start_date) / 2) do
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration2.id, user_id: @student1.id, percent_complete: 30
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration2.id, user_id: @student2.id, percent_complete: 60
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration2.id, user_id: @lecturer.id, percent_complete: 20
    end

    Timecop.travel @iteration2.deadline - 1.hour do
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration2.id, user_id: @student1.id, percent_complete: 20
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration2.id, user_id: @student2.id, percent_complete: 70
      create :project_evaluation, project_id: @project.id, iteration_id: @iteration2.id, user_id: @lecturer.id, percent_complete: 30
    end

    expect(@project.project_evaluations.length).to eq 12
    expect(@iteration1.project_evaluations.length).to eq 6
    expect(@iteration2.project_evaluations.length).to eq 6
  end

  before :each do
    host! 'api.example.com'
    post '/v1/sign_in', params: { email: @lecturer.email, password: '12345678' }
    expect(response.status).to eq(200)
    @csrf = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
  end

  it 'returns the correct data' do
      get "/v1/stats?graph=percent_completion&project_id=#{@project.id}", headers: { 'X-XSRF-TOKEN' => @csrf }

      #@student1, @csrf = login_integration @student1
      expect(status).to eq 200

      expect(body['percent_completion_graph'].length).to eq 2
      expect(body['percent_completion_graph'][0]['name']).to include 'Lecturer'
      expect(body['percent_completion_graph'][0]['data'].length).to eq 4
      expect(body['percent_completion_graph'][1]['name']).to include 'Student'
      expect(body['percent_completion_graph'][1]['data'].length).to eq 4
  end
end
