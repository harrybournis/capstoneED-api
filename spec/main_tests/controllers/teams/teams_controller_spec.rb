require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::TeamsController, type: :controller do

	StudentsTeam = JoinTables::StudentsTeam

	before(:all) do
		@lecturer = get_lecturer_with_units_projects_teams
		@student = FactoryGirl.create(:student_with_password).process_new_record
		@student.save
		@student.confirm
		Team.first.students << @student
		Team.last.students 	<< @student
	end

	context 'Student' do

		before(:each) do
			@controller = V1::TeamsController.new
			mock_request = MockRequest.new(valid = true, @student)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
		end

		describe 'GET index' do
			it "returns only the student's teams" do
				get :index
				expect(response.status).to eq(200)
				expect(parse_body['teams'].length).to eq(@student.teams.length)
				expect(@student.teams.length).to_not eq(Team.all.length)
			end
		end

		describe "GET show" do
			it 'returns the Team if the it belongs to the current_user' do
				get :show, params: { id: @student.teams.first.id }
				expect(response.status).to eq(200)
				expect(@student.teams.find(parse_body['team']['id'])).to be_truthy

				team = FactoryGirl.create(:team)
				get :show, params: { id: team.id }
				expect(response.status).to eq(403)
			end
		end

		describe 'POST create' do
			it 'responds with 403 forbidden is user is student' do
				expect {
					post :create, params: FactoryGirl.attributes_for(:team, project_id: Project.first.id)
				}.to_not change { Team.all.count }
				expect(response.status).to eq(403)
			end
		end

		describe 'PATCH update' do
			it 'updates the parameters successfully if student is member of the team' do
				expect {
					patch :update, params: { id: Team.first.id, name: 'CrazyTeam666', logo: 'http://www.images.com/images/4259' }
				}.to change { Team.first.name }
				expect(response.status).to eq(200)
				expect(parse_body['team']['logo']).to eq('http://www.images.com/images/4259')
			end

			it 'responds with 403 if student is not member of the Team' do
				team = FactoryGirl.create(:team)
				expect {
					patch :update, params: { id: team.id, name: 'Something' }
				}.to_not change { Team.first.name }
				expect(response.status).to eq(403)
			end

			it 'ignores the enrollment key update' do
				expect {
					patch :update, params: { id: Team.first.id, enrollment_key: 'new_key' }
				}.to_not change { Team.first.enrollment_key }
				expect(response.status).to eq(200)
			end
		end

		describe 'POST enrol' do
			it 'creates a new StudentsTeam instance' do
				team = FactoryGirl.create(:team)
				expect {
					post :enrol, params: { enrollment_key: team.enrollment_key }
				}.to change { StudentsTeam.all.count }.by(1)
				expect(response.status).to eq(201)
				@student.reload
				expect(@student.teams.include? team).to be_truthy
			end

			it 'responds with 422 unprocessable_entity if wrong enrollment key' do
				expect {
					post :enrol, params: { enrollment_key: 'invalidkey' }
				}.to_not change { StudentsTeam.all.count }
				expect(parse_body['errors']['enrollment_key'].first).to eq('is invalid')
			end

			it 'responds with 403 forbidden if they try to enrol on the same team twice' do
				expect {
					post :enrol, params: { enrollment_key: @student.teams.first.enrollment_key }
				}.to_not change { StudentsTeam.all.count }
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to eq('Student can not exist in the same Team twice')
			end

			it 'responds with 403 forbidden if they try to enrol on two teams for the same project' do
				team = @student.teams.first.project.teams.last
				expect(@student.teams.include? team).to be_falsy
				expect {
					post :enrol, params: { enrollment_key: team.enrollment_key }
				}.to_not change { StudentsTeam.all.count }
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to eq('Student has already enroled in a different team for this Project')
			end
		end

		describe 'DELETE destroy' do
			it 'responds with 403 forbidden if current_user is not a lecturer' do
				expect {
					delete :destroy, params: { id: @student.teams.first }
				}.to_not change { Team.all.count }
				expect(response.status).to eq(403)
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
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to include("Lecturers must provide a 'project_id' in the parameters for this route")
			end

			it 'returns the teams for the provided project_id if the project belongs to the current user' do
				project = @lecturer.projects.first
				get :index_with_project, params: { project_id: project.id }
				expect(response.status).to eq(200)
				expect(parse_body['teams'].length).to eq(project.teams.length)
			end

			it 'responds with 403 forbidden if project does not belong to current user' do
				project = FactoryGirl.create(:project)
				get :index, params: { project_id: project.id }
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to include("Lecturers must provide a 'project_id' in the parameters for this route.")
			end
		end

		describe 'GET show' do
			it 'returns the Team if the it belongs to the current_user' do
				get :show, params: { id: @lecturer.teams.first.id }
				expect(response.status).to eq(200)
				expect(@lecturer.teams.find(parse_body['team']['id'])).to be_truthy

				team = FactoryGirl.create(:team)
				get :show, params: { id: team.id }
				expect(response.status).to eq(403)
			end
		end

		describe "POST create" do
			it 'creates a new team if the current user is lecturer and owner of the project' do
				expect {
					post :create, params: FactoryGirl.attributes_for(:team, project_id: @lecturer.projects.last.id)
				}.to change { Team.all.count }.by(1)
				expect(response.status).to eq(201)
			end

			it 'responds with 403 forbidden if not the owner of the project' do
				different_project = FactoryGirl.create(:project)
				expect {
					post :create, params: FactoryGirl.attributes_for(:team, project_id: different_project.id)
				}.to_not change { Team.all.count }
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to eq("This Project is not associated with the current user")
			end
		end

		describe 'PATCH update' do
			it 'updates the parameters successfully if Lecturer owns the project' do
				expect {
					patch :update, params: { id: @lecturer.teams.first.id, name: 'CrazyTeam666', logo: 'http://www.images.com/images/4259' }
				}.to change { Team.first.name }
				expect(response.status).to eq(200)
				expect(parse_body['team']['logo']).to eq('http://www.images.com/images/4259')
			end

			it 'changes the enrollment_key successfully' do
				expect {
					patch :update, params: { id: Team.first.id, enrollment_key: 'new_key' }
				}.to change { Team.first.enrollment_key }
				expect(response.status).to eq(200)
			end
		end

		describe 'POST enrol' do
			it 'responds with 403 forbidden if lecturer' do
				expect {
					post :enrol, params: { enrollment_key: 'something' }
				}.to_not change { StudentsTeam.all.size }
				expect(response.status).to eq(403)
			end
		end

		describe 'DELETE destroy' do
			it 'destroys the team if the Lecturer is the onwer' do
				expect {
					delete :destroy, params: { id: @lecturer.teams.first.id }
				}.to change { Team.all.size }
				expect(response.status).to eq(204)
			end

			it 'responds with 403 if current user is a Lecturer but not the onwer of the Project' do
				team = FactoryGirl.create(:team)
				expect {
					delete :destroy, params: { id: team.id }
				}.to_not change { Team.all.size }
				expect(response.status).to eq(403)
			end
		end
	end
end
