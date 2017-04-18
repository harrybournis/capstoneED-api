require 'rails_helper'

RSpec.describe "ProjectEvaluationPoints - Integration", type: :request do

  before(:all) do
    @lecturer = get_lecturer_with_units_assignments_projects
    @student = create :student_confirmed
    @project = @lecturer.projects.first
    @game_setting  = create :game_setting, assignment: @project.assignment
    create :students_project, student: @student, project: @project
    now = DateTime.now
    @project.assignment.start_date = now
    @project.assignment.end_date = now + 1.month
    @project.assignment.save
    @project.assignment.iterations << FactoryGirl.create(:iteration, start_date: now, deadline: now + 28.days)
    @feeling = FactoryGirl.create(:feeling)
  end

  before(:each) do
    host! 'api.example.com'

    post '/v1/sign_in', params: { email: @student.email, password: '12345678' }
    expect(response.status).to eq(200)
    @csrf = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
    @attr = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @student.id, project_id: @project.id, iteration_id: @project.iterations[0].id, feeling_id: @feeling.id)
  end

  describe 'Success' do
    it 'awards points for completing the project evaluation' do
      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to change { ProjectEvaluationPoint.where(student_id: @student.id, reason_id: Reason[:project_evaluation][:id]).count }

      expect(status).to eq 201
      @point = ProjectEvaluationPoint.where(student_id: @student.id, project_evaluation_id: body['project_evaluation']['id'], reason_id: Reason[:project_evaluation][:id]).last
      expect(@point.points).to eq @game_setting.points_project_evaluation
    end

    it 'awards points for completing the project evaluation first in the team' do
      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to change { ProjectEvaluationPoint.where(student_id: @student.id, reason_id: Reason[:project_evaluation_first_of_team][:id]).count }

      expect(status).to eq 201
      @point = ProjectEvaluationPoint.where(student_id: @student.id, project_evaluation_id: body['project_evaluation']['id'], reason_id: Reason[:project_evaluation_first_of_team][:id]).last
      expect(@point.points).to eq @game_setting.points_project_evaluation_first_of_team
    end

    it 'awards points for completing the project evaluation first in the team and the lecturer already submitted' do
      create(:project_evaluation, user: @lecturer, project_id: @project.id, iteration_id: @project.iterations[0].id)

      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to change { ProjectEvaluationPoint.where(student_id: @student.id, reason_id: Reason[:project_evaluation_first_of_team][:id]).count }

      expect(status).to eq 201
      @point = ProjectEvaluationPoint.where(student_id: @student.id, project_evaluation_id: body['project_evaluation']['id'], reason_id: Reason[:project_evaluation_first_of_team][:id]).last
      expect(@point.points).to eq @game_setting.points_project_evaluation_first_of_team
    end

    it 'awards points for completing the project evaluation first in the assignment' do
      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to change { ProjectEvaluationPoint.where(student_id: @student.id, reason_id: Reason[:project_evaluation_first_of_assignment][:id]).count }

      expect(status).to eq 201
      @point = ProjectEvaluationPoint.where(student_id: @student.id, project_evaluation_id: body['project_evaluation']['id'], reason_id: Reason[:project_evaluation_first_of_assignment][:id]).last
      expect(@point.points).to eq @game_setting.points_project_evaluation_first_of_assignment
    end

    it 'awards points for completing the project evaluation first in the assignment and the lecturer already submitted' do
      create(:project_evaluation, user: @lecturer, project_id: @project.id, iteration_id: @project.iterations[0].id)

      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to change { ProjectEvaluationPoint.where(student_id: @student.id, reason_id: Reason[:project_evaluation_first_of_assignment][:id]).count }

      expect(status).to eq 201
      @point = ProjectEvaluationPoint.where(student_id: @student.id, project_evaluation_id: body['project_evaluation']['id'], reason_id: Reason[:project_evaluation_first_of_assignment][:id]).last
      expect(@point.points).to eq @game_setting.points_project_evaluation_first_of_assignment
    end
  end

  describe 'Failure' do
    it 'does not award points if user is a lecturer' do
      @lecturer, @csrf_lecturer = login_integration @lecturer
      @attr_lecturer = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @lecturer.id, project_id: @project.id, iteration_id: @project.iterations[0].id, feeling_id: @feeling.id)

      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr_lecturer, headers: { 'X-XSRF-TOKEN' => @csrf_lecturer }
      }.to_not change { ProjectEvaluationPoint.where(student_id: @lecturer.id, reason_id: Reason[:project_evaluation][:id]).count }

      expect(status).to eq 201
      @point = ProjectEvaluationPoint.where(student_id: @lecturer.id, project_evaluation_id: body['project_evaluation']['id'], reason_id: Reason[:project_evaluation][:id]).last
      expect(@point).to be_falsy
    end
    it 'does not award points if not the first in the team' do
    	@student2 = create :student_confirmed
			create :students_project, student: @student2, project: @project
			create(:project_evaluation, user: @student2, project_id: @project.id, iteration_id: @project.iterations[0].id)

      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to_not change { ProjectEvaluationPoint.where(student_id: @student.id, reason_id: Reason[:project_evaluation_first_of_team][:id]).count }

      expect(status).to eq 201
      @point = ProjectEvaluationPoint.where(student_id: @student.id, project_evaluation_id: body['project_evaluation']['id'], reason_id: Reason[:project_evaluation_first_of_team][:id]).last
      expect(@point).to be_falsy
    end
    it 'does not award point if not first in the assignment' do
      @irrelevant_team = create :project, assignment: @project.assignment
      @irrelevant_student = create :student_confirmed
      create :students_project, student: @irrelevant_student, project: @irrelevant_team
      create(:project_evaluation, user: @irrelevant_student, project_id: @irrelevant_team.id, iteration_id: @project.iterations[0].id)

      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to_not change { ProjectEvaluationPoint.where(student_id: @student.id, reason_id: Reason[:project_evaluation_first_of_assignment][:id]).count }

      expect(status).to eq 201
      @point = ProjectEvaluationPoint.where(student_id: @student.id, project_evaluation_id: body['project_evaluation']['id'], reason_id: Reason[:project_evaluation_first_of_assignment][:id]).last
      expect(@point).to be_falsy
    end
  end

  describe 'Profile points get updated' do
    it 'with points for project_evaluation, first of team, first of assignment' do
      expect(@student.points_for_project_id(@project.id)).to eq 0

      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to change {
        @student.points_for_project_id(@project.id)
      }.to(@game_setting.points_project_evaluation +
           @game_setting.points_project_evaluation_first_of_team +
           @game_setting.points_project_evaluation_first_of_assignment)

      expect(status).to eq 201
    end
  end

  describe 'Serialization' do
    it 'includes points in the json response' do
      expect(@student.points_for_project_id(@project.id)).to eq 0

      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to change { ProjectEvaluationPoint.where(student_id: @student.id, reason_id: Reason[:project_evaluation][:id]).count }

      expect(status).to eq 201

      new_points = 0
      ProjectEvaluationPoint.where(student_id: @student.id).each do |pap|
        new_points += pap.points
      end
      expect(@student.points_for_project_id(@project.id)).to eq new_points

      expect(body['points']).to be_truthy
      expect(body['points']['points_earned']).to eq new_points
      expect(body['points']['new_total']).to eq @student.points_for_project_id(@project.id)
      expect(body['points']['detailed']['project_evaluation']).to be_a Array
      expect(body['points']['detailed']['project_evaluation'].length).to eq ProjectEvaluationPoint.where(student_id: @student.id).count
      expect(body['points']['detailed']['project_evaluation'][0]['reason_id']).to be_truthy
      expect(body['points']['detailed']['project_evaluation'][0]['points']).to be_truthy
    end

    it 'does not include points in the response if the request was invalid' do
        @student, @csrf = login_integration @student

        @project.students.delete(@student)
        attr = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @student.id, project_id: @project.id, iteration_id: @project.iterations[0].id)

        expect {
          post "/v1/projects/#{@project.id}/evaluations", params: attr, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to_not change { ProjectEvaluationPoint.where(student_id: @student.id, reason_id: Reason[:project_evaluation][:id]).count }

        expect(status).to eq 422

        expect(body['points']).to be_falsy
    end

    it 'does not include points if current user is a lecturer' do
      @lecturer, @csrf_lecturer = login_integration @lecturer
      @attr_lecturer = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @lecturer.id, project_id: @project.id, iteration_id: @project.iterations[0].id, feeling_id: @feeling.id)

      expect {
        post "/v1/projects/#{@project.id}/evaluations", params: @attr_lecturer, headers: { 'X-XSRF-TOKEN' => @csrf_lecturer }
      }.to_not change { ProjectEvaluationPoint.where(student_id: @lecturer.id, reason_id: Reason[:project_evaluation][:id]).count }

      expect(status).to eq 201

      expect(body['points']).to be_falsy
    end
  end
end
