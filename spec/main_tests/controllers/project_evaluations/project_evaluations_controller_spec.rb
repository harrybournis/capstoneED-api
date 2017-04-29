require 'rails_helper'
require 'timecop'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::ProjectEvaluationsController, type: :controller do

  before(:all) do
    @lecturer = get_lecturer_with_units_assignments_projects
    @student = FactoryGirl.create(:student)
    @project = @lecturer.projects.first
    create :students_project, student: @student, project: @project
    now = DateTime.now
    @game_setting = create :game_setting, assignment: @project.assignment
    @project.assignment.start_date = now
    @project.assignment.end_date = now + 1.month
    @project.assignment.save
    @iteration = create :iteration, assignment: @project.assignment
    @feeling = FactoryGirl.create(:feeling)
  end

  context 'Student' do

    before(:each) do
      @controller = V1::ProjectEvaluationsController.new
      mock_request = MockRequest.new(valid = true, @student)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
    end

    it 'POST create creates new project_evaluation if student is in project', { docs?: true, lecturer?: false } do
      attr = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @student.id, project_id: @project.id, iteration_id: @project.iterations[0].id)
      post :create, params: attr

      expect(status).to eq(201)
    end

    it 'POST create creates new project_evaluation with feelings', { docs?: true, lecturer?: false } do
      attr = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @student.id, project_id: @project.id, iteration_id: @project.iterations[0].id, feelings: valid_feelings_params)

      expect {
        post :create, params: attr
      }.to change { FeelingsProjectEvaluation.count }.by 2

      expect(status).to eq(201)
    end
    it 'POST returns 422 unprocessable_entity if student does not belong in project', { docs?: true, lecturer?: false }  do
      @project.students.delete(@student)
      attr = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @student.id, project_id: @project.id, iteration_id: @project.iterations[0].id)
      post :create, params: attr

      expect(status).to eq(422)
      expect(errors['user_id'][0]).to include('not associated')
    end

    it 'POST returns 422 unprocessable_entity if iteration is not active', { docs?: true, lecturer?: false }  do
      Timecop.travel(DateTime.now + 2.months) do
        mock_request = MockRequest.new(valid = true, @student)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
        attr = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @student.id, project_id: @project.id, iteration_id: @project.iterations[0].id)
        post :create, params: attr

        expect(status).to eq(422)
        expect(errors['iteration_id'][0]).to include('currently active')
      end
    end

    it 'index returns 200 and the projects that can be evaluated without the students' do
      Timecop.travel @iteration.deadline - 1.hour do
        mock_request = MockRequest.new(valid = true, @student)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
        get :index

        expect(status).to eq 200
        expect(body['pending_evaluations']).to be_truthy
        expect(body['pending_evaluations'].length).to eq @student.projects.length
        expect(body['pending_evaluations'][0]['project_id']).to be_in @iteration.projects.ids
        expect(body['pending_evaluations'][0]['iteration_id']).to eq @iteration.id
        expect(body['pending_evaluations'][0]['team_answers']).to be_falsy
      end
    end

    it 'index returns 204 if no projects can be evaluated' do
      Timecop.travel @iteration.start_date + 2.hours do
        mock_request = MockRequest.new(valid = true, @student)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

        get :index
        expect(status).to eq 204
      end
    end

    # it 'PATCH update works only for lecturer' do
    # 	pe = FactoryGirl.create(:project_evaluation, user: @student, percent_complete: 89)
    # 	patch :update, params: { id: pe.id, project_id: pe.project_id, percent_complete: pe.percent_complete }

    # 	expect(status).to eq(403)
    # 	expect(errors['base'][0]).to include('must be Lecturer')
    # end

    it 'GET index_with_project returns project_health, team_health', { docs?: true } do
      FactoryGirl.create(:project_evaluation, user: @student, project_id: @project.id, iteration_id: @project.iterations[0].id)
      get :index_with_project, params: { project_id: @project.id }

      expect(status).to eq(200)
      expect(body['project']['project_health']).to eq(@project.project_health)
      expect(body['project']['team_health']).to eq(@project.team_health)
    end

    it 'GET index_with_iteration returns iteration_health', { docs?: true } do
      FactoryGirl.create(:project_evaluation, user: @student, project_id: @project.id, iteration_id: @project.iterations[0].id)
      get :index_with_iteration, params: { iteration_id: @project.iterations[0].id }

      expect(status).to eq(200)
      expect(body['iteration']['iteration_health']).to eq(@project.iterations[0].iteration_health)
    end
  end

  context 'Lecturer' do

    before(:each) do
      @controller = V1::ProjectEvaluationsController.new
      mock_request = MockRequest.new(valid = true, @lecturer)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
    end

    it 'POST create creates new project_evaluation if lecturer is in project' do
      attr = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @lecturer.id, project_id: @project.id, iteration_id: @project.iterations[0].id, feeling_id: @feeling.id)
      post :create, params: attr

      expect(status).to eq(201)
    end

    it 'POST create returns 422 unprocessable_entity if lecturer does not belong in project' do
      now = DateTime.now
      assignment = FactoryGirl.create(:assignment, start_date: now, end_date: now + 1.month)
      project = FactoryGirl.create(:project, assignment: assignment)
      iteration = FactoryGirl.create(:iteration, assignment: assignment, start_date: now + 1.minute, deadline: now + 28.days)

      attr = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @lecturer.id, iteration_id: iteration.id, project_id: project.id)
      post :create, params: attr

      expect(status).to eq(422)
      expect(errors['user_id'][0]).to include('not associated')
    end

    it 'POST create returns 422 unprocessable_entity if iteration is not active' do
      Timecop.travel(DateTime.now + 2.months) do
        mock_request = MockRequest.new(valid = true, @lecturer)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
        attr = FactoryGirl.attributes_for(:project_evaluation).merge(user_id: @lecturer.id, project_id: @project.id, iteration_id: @project.iterations[0].id)
        post :create, params: attr

        expect(status).to eq(422)
        expect(errors['iteration_id'][0]).to include('currently active')
      end
    end

    it 'index returns 200 and the projects that can be evaluated with the students' do
      Timecop.travel @iteration.deadline - 1.hour do
        mock_request = MockRequest.new(valid = true, @lecturer)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

        @iteration.projects.each do |project|
          expect(project.pending_evaluation(@lecturer)).to be_truthy
        end

        get :index

        expect(status).to eq 200
        expect(body['pending_evaluations']).to be_truthy
        expect(body['pending_evaluations'].length).to eq @iteration.projects.length
        expect(body['pending_evaluations'][0]['project_id']).to be_in @iteration.projects.ids
        expect(body['pending_evaluations'][0]['iteration_id']).to eq @iteration.id
        expect(body['pending_evaluations'][0]['team_answers']).to be_truthy
        expect(body['pending_evaluations'][0]['team_answers'].length).to eq Project.find( body['pending_evaluations'][0]['project_id']).students.count
      end
    end
    it 'index returns 204 if no projects can be evaluated' do
      Timecop.travel @iteration.start_date + 2.hours do
        mock_request = MockRequest.new(valid = true, @lecturer)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

        get :index
        expect(status).to eq 204
      end
    end

    # it 'PATCH update updates the percent and feeling', { docs?: true } do
    # 	pe = FactoryGirl.create(:project_evaluation_lecturer, user: @lecturer, percent_complete: 89)
    # 	patch :update, params: { id: pe.id, project_id: pe.project_id, percent_complete: pe.percent_complete }

    # 	expect(status).to eq(200)
    # 	expect(body['project_evaluation']['percent_complete']).to eq 89
    # end
  end
end
