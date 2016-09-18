require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe 'Includes', type: :controller do

	context 'Lecturer' do

		before(:all) do
			@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
			@lecturer.save
			@lecturer.confirm
			@unit = FactoryGirl.create(:unit, lecturer: @lecturer)
			@project = FactoryGirl.create(:project_with_teams, unit: @unit, lecturer: @lecturer)
			3.times { @project.teams.first.students << FactoryGirl.build(:student) }
			expect(@project.teams.length).to eq(2)
			expect(@project.teams.first.students.length).to eq(3)
		end

		before(:each) do
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'Projects' do

			before(:each) do
				@controller = V1::ProjectsController.new
			end

			it 'returns only the specified resource in includes' do
				get :show, params: { id: @project.id }
				body_project = body['project']
				expect(response.status).to eq(200) #1
				expect(body_project).to include('description', 'start_date')
				expect(body_project['teams']).to be_falsy
				expect(body_project['teams']).to be_falsy

				get :show, params: { id: @project.id, includes: 'teams'}
				body_project = body['project']
				expect(response.status).to eq(200) #2
				expect(body_project['teams']).to be_truthy
				expect(body_project['unit']).to be_falsy

				get :show, params: { id: @project.id, includes: 'teams,unit'}
				body_project = body['project']
				expect(response.status).to eq(200) #3
				expect(body_project['teams']).to be_truthy
				expect(body_project['unit']).to be_truthy
			end

			it 'returns the resource full but only the associations ids if ?compact=true' do
				get :show, params: { id: @project.id }
				body_project = body['project']
				expect(response.status).to eq(200)
				expect(body_project).to include('description', 'start_date')
				expect(body_project['teams']).to be_falsy
				expect(body_project['unit']).to be_falsy

				get :show, params: { id: @project.id, includes: 'teams', compact: true}
				body_project = body['project']
				expect(response.status).to eq(200)
				expect(body_project['teams']).to be_truthy
				expect(body_project['teams'].first).to_not include('name', 'enrollment_key')
				expect(body_project['unit']).to be_falsy

				get :show, params: { id: @project.id, includes: 'teams,unit'}
				body_project = body['project']
				expect(response.status).to eq(200)
				expect(body_project['teams']).to be_truthy
				expect(body_project['teams'].first).to include('name', 'enrollment_key')
				expect(body_project['unit']).to be_truthy
				expect(body_project['unit']).to include('code', 'semester')
			end

			it 'is invalid if * is in the includes' do
				get :show, params: { id: @project.id, includes: 'teams,*' }
				expect(status).to eq(400)
				expect(body['errors']['base'][0]).to include("Invalid 'includes' parameter")
			end

			it 'works for index' do
				get :index, params: { includes: 'unit' }
				expect(response.status).to eq(200)
				expect(body['projects'].first['unit']).to be_truthy
				expect(body['projects'].first['teams']).to be_falsy
			end

			it 'renders empty array if no collection is empty' do
				@unit.projects.destroy_all
				expect(@unit.projects.empty?).to be_truthy
				get :index, params: { unit_id: @unit.id, includes: 'lecturer' }
				expect(response.status).to eq(204)
				expect(response.body.empty?).to be_truthy
			end

			it 'renders no associations if includes emtpy string?' do
				get :show, params: { id: @project.id, includes: "" }
				expect(body['project']['unit']).to be_falsy
				expect(body['project']['teams']).to be_falsy
			end

			it 'includes iterations' do
				3.times { FactoryGirl.create(:iteration, project_id: @project.id) }
				expect {
					get :show, params: { id: @project.id, includes: 'iterations,students' }
				}.to make_database_queries(count: 1)
				expect(status).to eq(200)
				expect(body['project']['iterations'].length).to eq(@project.iterations.length)
				expect(body['project']['iterations'][0]['name']).to eq(Iteration.find(body['project']['iterations'][0]['id']).name)
				expect(body['project']['students'].length).to eq(@project.students.length)
			end
		end

		describe 'Units' do
			before(:each) do
				@controller = V1::UnitsController.new
			end

			it 'GET show contains projects' do
				get :show, params: { id: @unit.id }
				expect(body['unit']['projects']).to be_falsy

				get :show, params: { id: @unit.id, includes: 'projects' }
				expect(body['unit']['projects']).to be_truthy
			end

			it 'GET index contains the projects compact' do
				get :index, params: { includes: 'projects', compact: true }
				expect(body['units'].first['projects'].first).to_not include('description')
			end
		end

		describe 'Teams' do
			before(:each) do
				@controller = V1::TeamsController.new
			end

			it 'GET show contains students' do
				get :show, params: { id: @project.teams.first.id }
				expect(status).to eq(200)
				expect(body['team']['enrollment_key']).to be_truthy

				get :show, params: { id: @project.teams.first.id, includes: 'students' }
				expect(status).to eq(200)
				expect(body['team']['students'].length).to eq(@project.teams.first.students.length)
			end

			it 'GET index contains students and project compact' do
				get :index_with_project, params: { project_id: @project.id, includes: 'students,project', compact: true }
				expect(status).to eq(200)
				team = body['teams'].first
				expect(team['students'].first['email']).to be_falsy
				expect(team['students'].first['provider']).to be_falsy
				expect(team['project']).to_not include('description')
				expect(team['project']['id']).to eq(@project.id)
				expect(team['lecturer']).to be_falsy
			end
		end
	end
end
