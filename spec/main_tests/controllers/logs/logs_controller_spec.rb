require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::LogsController, type: :controller do

  before(:all) do
    @lecturer = get_lecturer_with_units_assignments_projects
    @student = FactoryGirl.create(:student_with_password).process_new_record
    @student.save
    @student.confirm
    create :students_project, student: @student, project: @lecturer.projects.first
    create :students_project, student: @student, project: @lecturer.projects.last
  end

  context 'Student' do

    before(:each) do
      @controller = V1::LogsController.new
      mock_request = MockRequest.new(valid = true, @student)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
    end

    describe 'POST /logs' do
      it 'responds with 200 if valid', { docs?: true, lecturer?: false, controller_class: "V1::ProjectsController" } do
        parameters = FactoryGirl.build(:students_project).logs[0].except(:date_submitted).merge(id: @student.projects[0].id)
        post :update, params: parameters
        expect(status).to eq(200)

        expect(body['log_entry']).to be_truthy
        expect(body['log_entry']).to eq parameters.except(:id)
      end

      it 'responds with 422 if invalid log parameters', { docs?: true, lecturer?: false, controller_class: "V1::ProjectsController" } do
        post :update, params: FactoryGirl.build(:students_project).logs[0].except("date_submitted", "time_worked").merge(id: @student.projects[0].id)
        expect(status).to eq(422)
        expect(errors['log_entry'][0]).to include('is missing')
      end

      it 'responds with 403 if not enrolled in project' do
        project = FactoryGirl.create(:project)
        post :update, params: FactoryGirl.attributes_for(:students_project).merge(id: project.id)
        expect(status).to eq(403)
      end
    end

    describe 'GET /logs' do
      it 'responds with 200 and the students logs', { docs?: true, lecturer?: false, controller_class: "V1::ProjectsController" } do
        project = @student.projects[0]
        sp = JoinTables::StudentsProject.where(project_id: project.id, student_id: @student.id)[0]
        sp.logs = []
        expect(sp.save).to be_truthy
        sp.add_log(FactoryGirl.build(:students_project).logs[0])
        expect(sp.save).to be_truthy
        sp.add_log(FactoryGirl.build(:students_project).logs[0])
        expect(sp.save).to be_truthy

        get :index_student, params: { id: project.id }

        expect(status).to eq(200)
        expect(body["logs"].length).to eq(2)
      end

      it 'responds with 403 if the student does not belong to project' do
        project = FactoryGirl.create(:project)
        get :index_student, params: {  id: project.id }
        expect(status).to eq(403)
      end
    end
  end

  context 'Lecturer' do

    before(:each) do
      @controller = V1::LogsController.new
      mock_request = MockRequest.new(valid = true, @lecturer)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
    end

    describe 'GET /logs' do
      it 'responds with 200 and the students logs', { docs?: true, controller_class: "V1::ProjectsController" } do
        project = @student.projects[0]
        sp = JoinTables::StudentsProject.where(project_id: project.id, student_id: @student.id)[0]
        sp.logs = []
        expect(sp.save).to be_truthy
        sp.add_log(FactoryGirl.build(:students_project).logs[0])
        expect(sp.save).to be_truthy
        sp.add_log(FactoryGirl.build(:students_project).logs[0])
        expect(sp.save).to be_truthy

        get :index_lecturer, params: { id: project.id, student_id: @student.id }

        expect(status).to eq(200)
        expect(body["logs"].length).to eq(2)
      end

      it 'responds with 200 if no logs' do
        assignment = create :assignment, lecturer: @lecturer
        expect(assignment.valid?).to be_truthy
        project = create :project, assignment: assignment
        expect(project.valid?).to be_truthy
        sp = build :students_project, project: project, student: @student
        sp.logs = []
        expect(sp.save).to be_truthy
        expect(sp.logs).to eq []
        @student.reload
        expect(@student.projects.include?(sp.project)).to be_truthy

        get :index_lecturer, params: { id: sp.project.id, student_id: @student.id }

        expect(status).to eq 200
        expect(body['logs']).to eq []
      end

      it 'responds with 422 if the student does not belong to project' do
        project = @lecturer.projects.second
        get :index_lecturer, params: {  id: project.id, student_id: @student.id }
        expect(status).to eq(422)
        expect(errors["student_id"][0]).to include("does not belong to this project")
      end

      it 'responds with 403 if the project does not belong to the lecturer' do
        project = FactoryGirl.create(:project)
        get :index_lecturer, params: {  id: project.id, student_id: @student.id }
        expect(status).to eq(403)
      end
    end
  end

end
