require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::TeamsController, type: :controller do

	StudentsTeam = JoinTables::StudentsTeam

	before(:all) do
		@lecturer = get_lecturer_with_units_projects_teams
		@student = FactoryGirl.create(:student_with_password).process_new_record
		@student.save
		@student.confirm
		@lecturer.teams.first.students << @student
		@lecturer.teams.last.students 	<< @student
	end

	context 'Student' do

		before(:each) do
			@controller = V1::TeamsController.new
			mock_request = MockRequest.new(valid = true, @student)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'GET index' do
			it "returns only the student's teams" do
				get :index
				expect(status).to eq(200)
				expect(parse_body['teams'].length).to eq(@student.teams.length)
				expect(@student.teams.length).to_not eq(Team.all.length)
			end
		end

		describe "GET show" do
			it 'returns the Team if the it belongs to the current_user' do
				get :show, params: { id: @student.teams.first.id }
				expect(status).to eq(200)
				expect(@student.teams.find(parse_body['team']['id'])).to be_truthy

				team = FactoryGirl.create(:team)
				get :show, params: { id: team.id }
				expect(status).to eq(403)
			end
		end

		describe 'POST create' do
			it 'responds with 403 forbidden is user is student' do
				expect {
					post :create, params: FactoryGirl.attributes_for(:team, project_id: Project.first.id)
				}.to_not change { Team.all.count }
				expect(status).to eq(403)
			end
		end

		describe 'PATCH update' do
			it 'updates the parameters successfully if student is member of the team' do
				expect {
					patch :update, params: { id: Team.first.id, name: 'CrazyTeam666', logo: 'http://www.images.com/images/4259' }
				}.to change { Team.first.name }
				expect(status).to eq(200)
				expect(parse_body['team']['logo']).to eq('http://www.images.com/images/4259')
			end

			it 'responds with 403 if student is not member of the Team' do
				team = FactoryGirl.create(:team)
				expect {
					patch :update, params: { id: team.id, name: 'Something' }
				}.to_not change { Team.first.name }
				expect(status).to eq(403)
			end

			it 'ignores the enrollment key update' do
				expect {
					patch :update, params: { id: Team.first.id, enrollment_key: 'new_key' }
				}.to_not change { Team.first.enrollment_key }
				expect(status).to eq(200)
			end
		end

		describe 'POST enrol' do
			it 'creates a new StudentsTeam instance' do
				team = FactoryGirl.create(:team)
				expect {
					post :enrol, params: { enrollment_key: team.enrollment_key }
				}.to change { StudentsTeam.all.count }.by(1)
				expect(status).to eq(201)
				@student.reload
				expect(@student.teams.include? team).to be_truthy
			end

			it 'responds with 422 unprocessable_entity if wrong enrollment key' do
				expect {
					post :enrol, params: { enrollment_key: 'invalidkey' }
				}.to_not change { StudentsTeam.all.count }
				expect(errors['enrollment_key'].first).to eq('is invalid')
			end

			it 'responds with 403 forbidden if they try to enrol on the same team twice' do
				expect {
					post :enrol, params: { enrollment_key: @student.teams.first.enrollment_key }
				}.to_not change { StudentsTeam.all.count }
				expect(status).to eq(403)
				expect(errors['base'].first).to eq('Student can not exist in the same Team twice')
			end

			it 'responds with 403 forbidden if they try to enrol on two teams for the same project' do
				team = @student.teams.first.project.teams.last
				expect(@student.teams.include? team).to be_falsy
				expect {
					post :enrol, params: { enrollment_key: team.enrollment_key }
				}.to_not change { StudentsTeam.all.count }
				expect(status).to eq(403)
				expect(errors['base'].first).to eq('Student has already enroled in a different team for this Project')
			end
		end

		describe 'DELETE destroy' do
			it 'responds with 403 forbidden if current_user is not a lecturer' do
				expect {
					delete :destroy, params: { id: @student.teams.first }
				}.to_not change { Team.all.count }
				expect(status).to eq(403)
			end
		end
	end

	context 'Lecturer' do

		before(:each) do
			@controller = V1::TeamsController.new
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'GET index' do
			it "responds with 403 forbidden if the params don't indlude project_id" do
				get :index
				expect(status).to eq(403)
				expect(errors['base'].first).to include("Lecturers must provide a 'project_id' in the parameters for this route")
			end

			it 'returns the teams for the provided project_id if the project belongs to the current user' do
				project = @lecturer.projects.first
				get :index_with_project, params: { project_id: project.id }
				expect(status).to eq(200)
				expect(parse_body['teams'].length).to eq(project.teams.length)
			end

			it 'responds with 403 forbidden if project does not belong to current user' do
				project = FactoryGirl.create(:project)
				get :index, params: { project_id: project.id }
				expect(status).to eq(403)
				expect(errors['base'].first).to include("Lecturers must provide a 'project_id' in the parameters for this route.")
			end
		end

		describe 'GET show' do
			it 'returns the Team if the it belongs to the current_user' do
				get :show, params: { id: @lecturer.teams.first.id }
				expect(status).to eq(200)
				expect(@lecturer.teams.find(parse_body['team']['id'])).to be_truthy

				team = FactoryGirl.create(:team)
				get :show, params: { id: team.id }
				expect(status).to eq(403)
			end
		end

		describe "POST create" do
			it 'creates a new team if the current user is lecturer and owner of the project' do
				expect {
					post :create, params: FactoryGirl.attributes_for(:team, project_id: @lecturer.projects.last.id)
				}.to change { Team.all.count }.by(1)
				expect(status).to eq(201)
			end

			it 'responds with 403 forbidden if not the owner of the project' do
				different_project = FactoryGirl.create(:project)
				expect {
					post :create, params: FactoryGirl.attributes_for(:team, project_id: different_project.id)
				}.to_not change { Team.all.count }
				expect(status).to eq(403)
				expect(errors['base'].first).to eq("This Project is not associated with the current user")
			end
		end

		describe 'PATCH update' do
			it 'updates the parameters successfully if Lecturer owns the project' do
				expect {
					patch :update, params: { id: @lecturer.teams.first.id, name: 'CrazyTeam666', logo: 'http://www.images.com/images/4259' }
				}.to change { Team.first.name }
				expect(status).to eq(200)
				expect(parse_body['team']['logo']).to eq('http://www.images.com/images/4259')
			end

			it 'changes the enrollment_key successfully' do
				expect {
					patch :update, params: { id: Team.first.id, enrollment_key: 'new_key' }
				}.to change { Team.first.enrollment_key }
				expect(status).to eq(200)
			end
		end

		describe 'POST enrol' do
			it 'responds with 403 forbidden if lecturer' do
				expect {
					post :enrol, params: { enrollment_key: 'something' }
				}.to_not change { StudentsTeam.all.size }
				expect(status).to eq(403)
			end
		end

		describe 'DELETE destroy' do
			it 'destroys the team if the Lecturer is the onwer' do
				expect {
					delete :destroy, params: { id: @lecturer.teams.first.id }
				}.to change { Team.all.size }
				expect(status).to eq(204)
			end

			it 'responds with 403 if current user is a Lecturer but not the onwer of the Project' do
				team = FactoryGirl.create(:team)
				expect {
					delete :destroy, params: { id: team.id }
				}.to_not change { Team.all.size }
				expect(status).to eq(403)
			end
		end

		describe 'DELETE remove_student' do
			it 'removes student from team if Lecturer is owner' do
				@lecturer.reload
				expect(@lecturer.teams.first.students.length).to eq(1)
				delete :remove_student, params: { id: @lecturer.teams[0].id, student_id: @lecturer.teams[0].students[0] }
				expect(status).to eq(204)
				@lecturer.reload
				expect(@lecturer.teams.first.students.length).to eq(0)
			end

			it 'responds with 400 if no student_id present in params' do
				delete :remove_student, params: { id: @lecturer.teams[0].id }
				expect(status).to eq(400)
				expect(errors['student_id'][0]).to eq("can't be blank")
			end

			it 'responds with 422 if student_id does not belong in team' do
				team = FactoryGirl.create(:team)
				other_student = FactoryGirl.create(:student)
				team.students << other_student
				delete :remove_student, params: { id: @lecturer.teams[0].id, student_id: other_student.id }
				expect(status).to eq(422)
				expect(errors['base'][0]).to include("Can't find Student")
				@lecturer.reload
				expect(@lecturer.teams.first.students.length).to eq(1)
			end
		end
	end
end
