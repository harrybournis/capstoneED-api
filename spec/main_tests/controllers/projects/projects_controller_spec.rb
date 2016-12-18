require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::ProjectsController, type: :controller do

	StudentsProject = JoinTables::StudentsProject

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
			it "returns only the student's projects" do
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
					patch :update, params: { id: Project.first.id, name: 'CrazyProject666', logo: 'http://www.images.com/images/4259' }
				}.to change { Project.first.name }
				expect(status).to eq(200)
				expect(parse_body['project']['logo']).to eq('http://www.images.com/images/4259')
			end

			it 'responds with 403 if student is not member of the Project' do
				project = FactoryGirl.create(:project)
				expect {
					patch :update, params: { id: project.id, name: 'Something' }
				}.to_not change { Project.first.name }
				expect(status).to eq(403)
			end

			it 'ignores the enrollment key update' do
				expect {
					patch :update, params: { id: Project.first.id, enrollment_key: 'new_key' }
				}.to_not change { Project.first.enrollment_key }
				expect(status).to eq(200)
			end
		end

		describe 'POST enrol' do
			it 'creates a new StudentsProject instance' do
				project = FactoryGirl.create(:project)
				expect {
					post :enrol, params: { enrollment_key: project.enrollment_key }
				}.to change { StudentsProject.all.count }.by(1)
				expect(status).to eq(201)
				@student.reload
				expect(@student.projects.include? project).to be_truthy
			end

			it 'responds with 422 unprocessable_entity if wrong enrollment key' do
				expect {
					post :enrol, params: { enrollment_key: 'invalidkey' }
				}.to_not change { StudentsProject.all.count }
				expect(errors['enrollment_key'].first).to eq('is invalid')
			end

			it 'responds with 403 forbidden if they try to enrol on the same project twice' do
				expect {
					post :enrol, params: { enrollment_key: @student.projects.first.enrollment_key }
				}.to_not change { StudentsProject.all.count }
				expect(status).to eq(403)
				expect(errors['base'].first).to eq('Student can not exist in the same Project twice')
			end

			it 'responds with 403 forbidden if they try to enrol on two projects for the same project' do
				project = @student.projects.first.assignment.projects.last
				expect(@student.projects.include? project).to be_falsy
				expect {
					post :enrol, params: { enrollment_key: project.enrollment_key }
				}.to_not change { StudentsProject.all.count }
				expect(status).to eq(403)
				expect(errors['base'].first).to eq('Student has already enroled in a different Project for this Assignment')
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
			it "responds with 403 forbidden if the params don't indlude assignment_id" do
				get :index
				expect(status).to eq(403)
				expect(errors['base'].first).to include("Lecturers must provide a 'assignment_id' in the parameters for this route")
			end

			it 'returns the projects for the provided assignment_id if the project belongs to the current user' do
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
					patch :update, params: { id: @lecturer.projects.first.id, name: 'CrazyProject666', logo: 'http://www.images.com/images/4259' }
				}.to change { Project.first.name }
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

		describe 'POST enrol' do
			it 'responds with 403 forbidden if lecturer' do
				expect {
					post :enrol, params: { enrollment_key: 'something' }
				}.to_not change { StudentsProject.all.size }
				expect(status).to eq(403)
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

		describe 'DELETE remove_student' do
			it 'removes student from project if Lecturer is owner' do
				@lecturer.reload
				@lecturer.projects.first.students << FactoryGirl.create(:student)
				expect(@lecturer.projects.first.students.length).to eq(2)
				delete :remove_student, params: { id: @lecturer.projects[0].id, student_id: @lecturer.projects[0].students[1] }
				expect(status).to eq(204)
				@lecturer.reload
				expect(@lecturer.projects.first.students.length).to eq(1)
			end

			it 'responds with 400 if no student_id present in params' do
				delete :remove_student, params: { id: @lecturer.projects[0].id }
				expect(status).to eq(400)
				expect(errors['student_id'][0]).to eq("can't be blank")
			end

			it 'responds with 422 if student_id does not belong in project' do
				project = FactoryGirl.create(:project)
				other_student = FactoryGirl.create(:student)
				project.students << other_student
				delete :remove_student, params: { id: @lecturer.projects[0].id, student_id: other_student.id }
				expect(status).to eq(422)
				expect(errors['base'][0]).to include("Can't find Student")
				@lecturer.reload
				expect(@lecturer.projects.first.students.length).to eq(1)
			end
		end
	end
end
