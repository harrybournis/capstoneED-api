require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::TeamsController, type: :controller do

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
	end

	context 'Lecturer' do

		before(:each) do
			@controller = V1::TeamsController.new
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
		end

		describe 'GET index' do
			it "responds with 400 bad request if the params don't indlude project_id" do
				get :index
				expect(response.status).to eq(400)
				expect(parse_body['errors']['project_id'].first).to eq("can't be blank")
			end

			it 'returns the teams for the provided project_id if the project belongs to the current user' do
				project = @lecturer.projects.first
				get :index, params: { project_id: project.id }
				expect(response.status).to eq(200)
				expect(parse_body['teams'].length).to eq(project.teams.length)
			end

			it 'responds with 403 forbidden if project does not belong to current user' do
				project = FactoryGirl.create(:project)
				get :index, params: { project_id: project.id }
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to eq("This Project can not be found in the current user's Projects")
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
	end

	# describe "GET show" do

	# 	before(:each) do
	# 		@controller = V1::UnitsController.new
	# 		@lecturer = FactoryGirl.build(:lecturer_with_units).process_new_record
	# 		@lecturer.save
	# 		mock_request = MockRequest.new(valid = true, @lecturer)
	# 		request.cookies['access-token'] = mock_request.cookies['access-token']
	# 		request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
	# 		expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
	# 		expect(request.headers['X-XSRF-TOKEN']).to be_truthy
	# 	end

	# 	it "returns the unit if if is is one of the lectuer's units" do
	# 		get :show, params: { id: @lecturer.units.first.id }
	# 		expect(response.status).to eq(200)
	# 		expect(parse_body['unit']['id']).to eq(@lecturer.units.first.id)
	# 	end

	# 	it 'responds with 403 if unit does not belong to lecturer' do
	# 		new_unit = FactoryGirl.create(:unit)
	# 		get :show, params: { id: new_unit.id }
	# 		expect(response.status).to eq(403)
	# 		expect(parse_body['errors']['base'].first).to eq("This Unit can not be found in the current user's Units")
	# 	end

	# 	it 'responds with 403 if record is not found at all' do
	# 		get :show, params: { id: '3333df' }
	# 		expect(response.status).to eq(403)
	# 		expect(parse_body['errors']['base'].first).to eq("This Unit can not be found in the current user's Units")
	# 	end
	# end

	# describe 'PATCH update' do

	# 	before(:each) do
	# 		@controller = V1::UnitsController.new
	# 		@lecturer = FactoryGirl.build(:lecturer_with_units).process_new_record
	# 		@lecturer.save
	# 		mock_request = MockRequest.new(valid = true, @lecturer)
	# 		request.cookies['access-token'] = mock_request.cookies['access-token']
	# 		request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
	# 		expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
	# 		expect(request.headers['X-XSRF-TOKEN']).to be_truthy
	# 	end

	# 	it 'updates successfully if user is Lecturer and the owner' do
	# 		patch :update, params: { id: @lecturer.units.first.id, name: 'different', code: 'different' }
	# 		expect(response.status).to eq(200)
	# 		expect(parse_body['unit']['name']).to eq('different')
	# 	end

	# 	it 'assigns different department if department_id in params' do
	# 		department = FactoryGirl.create(:department)
	# 		patch :update, params: { id: @lecturer.units.first.id, department_id: department.id }
	# 		expect(response.status).to eq(200)
	# 		@lecturer.reload
	# 		expect(@lecturer.units.first.department_id).to eq(department.id)
	# 	end

	# 	it 'creates a new department if department_attributes in params' do
	# 		expect {
	# 			patch :update, params: { id: @lecturer.units.first.id, department_attributes: { name: 'departmentname', university: 'university' } }
	# 		}.to change { Department.all.count }.by(1)
	# 		expect(response.status).to eq(200)
	# 		@lecturer.reload
	# 		expect(@lecturer.units.first.department.name).to eq('departmentname')
	# 	end

	# 	it 'assigns the department_id if both department_id and department_attributes' do
	# 		department = FactoryGirl.create(:department)
	# 		expect {
	# 			patch :update, params: { id: @lecturer.units.first.id, department_id: department.id, department_attributes: { name: 'departmentname', university: 'university' } }
	# 		}.to_not change { Department.all.count }
	# 		expect(response.status).to eq(200)
	# 		@lecturer.reload
	# 		expect(@lecturer.units.first.department.name).to eq(department.name)
	# 	end
	# end

	# describe 'DELETE destroy' do

	# 	it 'delete the unit if user is lecturer and owner' do
	# 		@controller = V1::UnitsController.new
	# 		@lecturer = FactoryGirl.build(:lecturer_with_units).process_new_record
	# 		@lecturer.save
	# 		mock_request = MockRequest.new(valid = true, @lecturer)
	# 		request.cookies['access-token'] = mock_request.cookies['access-token']
	# 		request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
	# 		expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
	# 		expect(request.headers['X-XSRF-TOKEN']).to be_truthy

	# 		delete :destroy, params: { id: @lecturer.units.first.id }
	# 		expect(response.status).to eq(204)
	# 	end
	# end
end
