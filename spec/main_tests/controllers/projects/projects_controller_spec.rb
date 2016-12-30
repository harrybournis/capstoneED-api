require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::ProjectsController, type: :controller do

	before(:all) do
		@lecturer = get_lecturer_with_units_assignments_projects
		@student = FactoryGirl.create(:student_with_password).process_new_record
		@student.save
		@student.confirm
		@lecturer.projects.first.students << @student
		@lecturer.projects.last.students 	<< @student
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
		end

		describe "GET show" do
			it 'returns the Project if the it belongs to the current_user' do
				get :show, params: { id: @student.projects.first.id }
				expect(status).to eq(200)
				expect(@student.projects.find(parse_body['project']['id'])).to be_truthy

				project = FactoryGirl.create(:project)
				get :show, params: { id: project.id }
				expect(status).to eq(403)
			end
		end

		describe 'POST create' do
			it 'responds with 403 forbidden is user is student' do
				expect {
					post :create, params: FactoryGirl.attributes_for(:project, assignment_id: Assignment.first.id)
				}.to_not change { Project.all.count }
				expect(status).to eq(403)
			end
		end

		describe 'PATCH update' do
			it 'updates the parameters successfully if student is member of the project' do
				expect {
					patch :update, params: { id: Project.first.id, project_name: 'CrazyProject666', logo: 'http://www.images.com/images/4259' }
				}.to change { Project.first.project_name }
				expect(status).to eq(200)
				expect(parse_body['project']['logo']).to eq('http://www.images.com/images/4259')
			end

			it 'responds with 403 if student is not member of the Project' do
				project = FactoryGirl.create(:project)
				expect {
					patch :update, params: { id: project.id, project_name: 'Something' }
				}.to_not change { Project.first.project_name }
				expect(status).to eq(403)
			end

			it 'ignores the enrollment key update' do
				expect {
					patch :update, params: { id: Project.first.id, enrollment_key: 'new_key' }
				}.to_not change { Project.first.enrollment_key }
				expect(status).to eq(200)
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
			it "responds with 403 forbidden if the params don't indlude assignment_id", { docs?: true } do
				get :index
				expect(status).to eq(403)
				expect(errors['base'].first).to include("Lecturers must provide a 'assignment_id' in the parameters for this route")
			end

			it 'returns the projects for the provided assignment_id if the project belongs to the current user',
				{ docs?: true, described_action: "index" } do

				assignment = @lecturer.assignments.first
				get :index_with_assignment, params: { assignment_id: assignment.id }
				expect(status).to eq(200)
				expect(parse_body['projects'].length).to eq(assignment.projects.length)
			end

			it 'responds with 403 forbidden if project does not belong to current user' do
				assignment = FactoryGirl.create(:assignment)
				get :index, params: { assignment_id: assignment.id }
				expect(status).to eq(403)
				expect(errors['base'].first).to include("Lecturers must provide a 'assignment_id' in the parameters for this route.")
			end
		end

		describe 'GET show' do
			it 'returns the Project if the it belongs to the current_user' do
				get :show, params: { id: @lecturer.projects.first.id }
				expect(status).to eq(200)
				expect(@lecturer.projects.find(parse_body['project']['id'])).to be_truthy

				project = FactoryGirl.create(:project)
				get :show, params: { id: project.id }
				expect(status).to eq(403)
			end
		end

		describe "POST create" do
			it 'creates a new project if the current user is lecturer and owner of the project' do
				expect {
					post :create, params: FactoryGirl.attributes_for(:project, assignment_id: @lecturer.assignments.last.id)
				}.to change { Project.all.count }.by(1)
				expect(status).to eq(201)
			end

			it 'responds with 403 forbidden if not the owner of the assignment' do
				different_assignment = FactoryGirl.create(:assignment)
				expect {
					post :create, params: FactoryGirl.attributes_for(:project, assignment_id: different_assignment.id)
				}.to_not change { Project.all.count }
				expect(status).to eq(403)
				expect(errors['base'].first).to eq("This Assignment is not associated with the current user")
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

			it 'changes the enrollment_key successfully' do
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
				project = FactoryGirl.create(:project)
				expect {
					delete :destroy, params: { id: project.id }
				}.to_not change { Project.all.size }
				expect(status).to eq(403)
			end
		end

	end
end
