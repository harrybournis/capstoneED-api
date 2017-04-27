require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::ProjectsController, type: :controller do

  before(:all) do
    @lecturer = get_lecturer_with_units_assignments_projects
    @student = create :student_confirmed
    create :students_project, student: @student, project: @lecturer.projects.first
    create :students_project, student: @student, project: @lecturer.projects.last
  end

  context 'Student' do

    before(:each) do
      @controller = V1::ProjectsController.new
      mock_request = MockRequest.new(valid = true, @student)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
    end

    describe 'GET index' do
      it "returns only the student's projects", { docs?: true, lecturer?: false } do |example|
        get :index
        expect(status).to eq(200)
        expect(parse_body['projects'].length).to eq(@student.projects.length)
        expect(@student.projects.length).to_not eq(Project.all.length)
      end

      it "returns the student's nickname for all projects" do
        get :index

        expect(status).to eq(200)
        body['projects'].each do |project|
          expect(project['nickname']).to be_truthy
          expect(project['nickname']).to eq @student.nickname_for_project_id project['id']
        end
      end

      it "returns projects with team_points and team_average as attributes" do
        get :index
        expect(status).to eq(200)
        expect(body['projects'][0]['points'].keys).to include 'total'
        expect(body['projects'][0]['points'].keys).to include 'total'
      end

      it 'includes pending_evaluations? field for each project' do
        get :index
        expect(status).to eq 200

        body['projects'].each do |p|
          expect(p['pending_project_evaluation']).to be_in [true,false]
        end
      end

      it 'if pending_evaluations? current_iteration_id also exists' do
        @iteration = create :iteration, assignment: @student.assignments[0]

        Timecop.travel @iteration.deadline - 1.hour do
          mock_request = MockRequest.new(valid = true, @student)
          request.cookies['access-token'] = mock_request.cookies['access-token']
          request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

          get :index

          expect(status).to eq 200

          at_least_one_true = false
          body['projects'].each do |p|
            if p['pending_project_evaluation'] == true
            	at_least_one_true = true
              expect(p['current_iteration_id']).to be_truthy
              expect(p['current_iteration_id']).to eq @iteration.id
            else
              expect(p['current_iteration_id']).to eq nil
            end
          end

          expect(at_least_one_true).to eq true
        end
      end

    end

    describe "GET show" do
      it 'returns the Project if the it belongs to the current_user' do
        get :show, params: { id: @student.projects.first.id }
        expect(status).to eq(200)
        expect(@student.projects.find(parse_body['project']['id'])).to be_truthy

        project = create(:project)
        get :show, params: { id: project.id }
        expect(status).to eq(403)
      end

      it "returns the student's nickname for the project" do
        get :show, params: { id: @student.projects.first.id }

        expect(status).to eq(200)
        expect(body['project']['nickname']).to be_truthy
        expect(body['project']['nickname']).to eq @student.nickname_for_project_id @student.projects[0].id
      end

      it 'can include students' do
        project = @student.projects.first
        create :students_project, student: create(:student), project: project
        expect(project.students.count).to eq 2
        project.reload

        get :show, params: { id: project.id, includes: 'students' }

        expect(status).to eq(200)
        project.reload
        expect(body['project']['students'].length).to eq project.students.count
      end

      it "returns project with team_points and team_average as attributes" do
        get :show, params: { id: @student.projects.first.id }

        expect(status).to eq(200)
        expect(body['project']['points'].keys).to include 'total'
        expect(body['project']['points'].keys).to include 'average'
      end
    end

    describe 'POST create' do
      it 'responds with 403 forbidden is user is student' do
        expect {
          post :create, params: attributes_for(:project, assignment_id: Assignment.first.id)
        }.to_not change { Project.all.count }
        expect(status).to eq(403)
      end
    end

    describe 'PATCH update' do
      it 'updates the parameters successfully if student is member of the project', { docs?: true, lecturer?: false } do
        expect {
          patch :update, params: { id: Project.first.id, logo: 'http://www.images.com/images/4259' }
        }.to change { Project.first.logo }
        expect(status).to eq(200)
        expect(parse_body['project']['logo']).to eq('http://www.images.com/images/4259')
      end

      it 'responds with 403 if student is not member of the Project' do
        project = create(:project)
        expect {
          patch :update, params: { id: project.id, project_name: 'Something' }
        }.to_not change { Project.first.project_name }
        expect(status).to eq(403)
      end

      it 'returns bad request if no permitted parameters and only enrollment key' do
        expect {
          patch :update, params: { id: Project.first.id, enrollment_key: 'new_key' }
        }.to_not change { Project.first.enrollment_key }
        expect(status).to eq(400)
        expect(errors["base"][0]).to include("none of the given parameters")
      end

      it 'returns bad request if no permitted parameters and only project_name', { docs?: true, lecturer?: false } do
        expect {
          patch :update, params: { id: Project.first.id, project_name: "whatever" }
        }.to_not change { Project.first.project_name }
        expect(status).to eq(400)
        expect(errors["base"][0]).to include("none of the given parameters")
      end
    end

    describe 'DELETE destroy' do
      it 'responds with 403 forbidden if current_user is not a lecturer' do
        expect {
          delete :destroy, params: { id: @student.projects.first }
        }.to_not change { Project.all.count }
        expect(status).to eq(403)
      end
    end
  end

  context 'Lecturer' do

    before(:each) do
      @controller = V1::ProjectsController.new
      mock_request = MockRequest.new(valid = true, @lecturer)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
    end

    describe 'GET index' do
      # it "responds with 403 forbidden if the params don't indlude assignment_id", { docs?: true } do
      # 	get :index
      # 	expect(status).to eq(403)
      # 	expect(errors['base'].first).to include("Lecturers must provide")
      # end

      it 'returns the lecturers active projects', { docs?: true } do
        expect(@lecturer.units.first.archive).to be_truthy
        create :project

        get :index

        expect(status).to eq(200)
        expect(body['projects'].length).to eq(@lecturer.projects.active.count)
      end

      it 'returns 204 if no active projects', { docs?: true } do
        @lecturer.units.each { |unit| unit.archive unless unit.reload.archived? }
        @lecturer.units.each { |unit| expect(unit.reload.archived?).to be_truthy }
        expect(@lecturer.projects.active.count).to eq(0)

        get :index

        expect(status).to eq(204)
      end

      it 'returns the projects for the provided assignment_id if the project belongs to the current user',
        { docs?: true, described_action: "index" } do

        assignment = @lecturer.assignments.first
        get :index_with_assignment, params: { assignment_id: assignment.id }
        expect(status).to eq(200)
        expect(parse_body['projects'].length).to eq(assignment.projects.length)
      end

      it 'returns the projects for the provided unit_id if the project belongs to the current user',
        { docs?: true, described_action: "index" } do

        unit = @lecturer.assignments.first.unit
        expect(unit.projects).to_not be_empty

        get :index_with_unit, params: { unit_id: unit.id }

        expect(status).to eq(200)
        expect(parse_body['projects'].length).to eq(unit.projects.length)
      end

      it 'returns 204 if the assignment has no Projects' do
        unit = create :unit, lecturer: @lecturer
        assignment = create :assignment, lecturer: @lecturer
        expect(assignment.projects.count).to eq 0
        expect(assignment.lecturer).to eq @lecturer

        get :index_with_assignment, params: { assignment_id: assignment.id }

        expect(status).to eq(204)
      end

      it 'returns 204 the assignment does not belong to the user' do
        unit = create :unit
        assignment = create :assignment, lecturer: unit.lecturer
        expect(assignment.projects.count).to eq 0
        expect(assignment.lecturer).to_not eq @lecturer

        get :index_with_assignment, params: { assignment_id: assignment.id }

        expect(status).to eq(204)
      end
    end

    describe 'GET show' do
      it 'returns the Project if the it belongs to the current_user' do
        get :show, params: { id: @lecturer.projects.first.id }
        expect(status).to eq(200)
        expect(@lecturer.projects.find(parse_body['project']['id'])).to be_truthy

        project = create(:project)
        get :show, params: { id: project.id }
        expect(status).to eq(403)
      end
    end

    describe "POST create" do
      it 'creates a new project if the current user is lecturer and owner of the project', { docs?: true } do
        expect {
          post :create, params: attributes_for(:project, assignment_id: @lecturer.assignments.last.id).except(:color)
        }.to change { Project.all.count }.by(1)
        expect(status).to eq(201)
      end

      it 'responds with 403 forbidden if not the owner of the assignment', { docs?: true } do
        different_assignment = create(:assignment)
        expect {
          post :create, params: attributes_for(:project, assignment_id: different_assignment.id)
        }.to_not change { Project.all.count }
        expect(status).to eq(403)
        expect(errors['base'].first).to eq("This Assignment is not associated with the current user")
      end

      it 'generates a random color for the project' do
        expect {
          post :create, params: attributes_for(:project, assignment_id: @lecturer.assignments.last.id)
        }.to change { Project.all.count }.by(1)
        expect(status).to eq(201)
        expect(body['project']['color']).to be_truthy
      end
    end

    describe 'PATCH update' do
      it 'updates the parameters successfully if Lecturer owns the project' do
        expect {
          patch :update, params: { id: @lecturer.projects.first.id, project_name: 'CrazyProject666', logo: 'http://www.images.com/images/4259' }
        }.to change { Project.first.project_name }
        expect(status).to eq(200)
        expect(parse_body['project']['logo']).to eq('http://www.images.com/images/4259')
      end

      it 'changes the enrollment_key successfully', { docs?: true } do
        expect {
          patch :update, params: { id: Project.first.id, enrollment_key: 'new_key' }
        }.to change { Project.first.enrollment_key }
        expect(status).to eq(200)
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the project if the Lecturer is the onwer' do
        expect {
          delete :destroy, params: { id: @lecturer.projects.first.id }
        }.to change { Project.all.size }
        expect(status).to eq(204)
      end

      it 'responds with 403 if current user is a Lecturer but not the onwer of the Project' do
        project = create(:project)
        expect {
          delete :destroy, params: { id: project.id }
        }.to_not change { Project.all.size }
        expect(status).to eq(403)
      end
    end

  end
end
