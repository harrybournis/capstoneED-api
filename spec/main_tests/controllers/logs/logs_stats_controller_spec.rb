require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::Logs::StatsController, type: :request do

  before(:all) do
    @lecturer = create :lecturer_confirmed
    @unit = create :unit, lecturer: @lecturer
    @assignment = create :assignment, unit: @unit, lecturer: @lecturer
    @iteration1 = build :iteration, assignment: @assignment
    @iteration1.save validate: false
    @iteration2 = build :iteration, assignment: @assignment
    @iteration2.save validate: false
    @project = create :project, assignment: @assignment
    @game_setting = create :game_setting, assignment: @assignment
    @student1 = create :student_confirmed
    @student2 = create :student_confirmed
    @sp1 = create :students_project, student: @student1, project: @project
    @sp2 = create :students_project, student: @student2, project: @project

    0..20.times do |n|
      Timecop.travel @project.iterations.first.start_date + n.days + 1.minute do
        [@sp1, @sp2].each do |sp|
          sp.add_log(JSON.parse({ date_worked: DateTime.now.to_i.to_s,
                                  date_submitted: DateTime.now.to_i.to_s,
                                  time_worked: [3,4,5,6,7,8,10].sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
          sp.save
        end
      end
    end

    @sp1.reload
    @sp2.reload
    expect(@sp1.logs.length).to eq 21
    expect(@sp2.logs.length).to eq 21
  end

  before :each do
    host! 'api.example.com'
    post '/v1/sign_in', params: { email: @lecturer.email, password: '12345678' }
    expect(response.status).to eq(200)
    @csrf = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
  end

  describe 'GET hours_worked' do

    it 'GET hours_worked works' do
      get "/v1/stats?graph=hours_worked&project_id=#{@project.id}", headers: { 'X-XSRF-TOKEN' => @csrf }

      expect(status).to eq 200

      expect(body['hours_worked_graph'].length).to eq @project.students.length
      expect(Time.at(body['hours_worked_graph'][0]['data'][0][0].to_i / 1000).to_datetime).to be_truthy
      expect(Time.at(body['hours_worked_graph'][0]['data'][0][0].to_i / 1000).to_datetime).to eq Time.at(@sp1.logs[0]['date_worked'].to_i).to_datetime
    end

    it 'GET hours_worked returns 400 bad request if no project_id in params' do
      get "/v1/stats?graph=hours_worked", headers: { 'X-XSRF-TOKEN' => @csrf }

      expect(status).to eq 400
      expect(errors_base[0]).to include 'needs a project_id'
    end

    it 'GET hours_worked returns 403 forbidden if the project_id is not associated with lecturer' do
      project = create :project
      get "/v1/stats?graph=hours_worked&project_id=#{project.id}", headers: { 'X-XSRF-TOKEN' => @csrf }

      expect(status).to eq 403
      expect(errors['base'][0]).to include 'associated'
    end

    it 'GET hours_worked returns 403 forbidden current user is a student' do
      @student1, @csrf = login_integration @student1

      get "/v1/stats?graph=hours_worked&project_id=#{@project.id}", headers: { 'X-XSRF-TOKEN' => @csrf }

      expect(status).to eq 403
      expect(errors['base'][0]).to include 'Lecturer'
    end
  end

end
