require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe 'Includes', type: :controller do

	context 'Lecturer' do

		before(:all) do
			@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
			@lecturer.save
			@lecturer.confirm
		end

		before(:each) do
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'Projects' do

			before(:each) do
				@controller = V1::ProjectsController.new
				@unit = FactoryGirl.create(:unit, lecturer: @lecturer)
				@project = FactoryGirl.create(:project_with_teams, unit: @unit, lecturer: @lecturer)
				expect(@project.teams.size).to eq(2)
			end

			it 'returns only the specified resource in includes' do
				get :show, params: { id: @project.id }
				body_project = parse_body['project']
				expect(response.status).to eq(200) #1
				expect(body_project).to include('description', 'start_date')
				expect(body_project['teams']).to be_falsy
				expect(body_project['teams']).to be_falsy

				get :show, params: { id: @project.id, includes: 'teams'}
				body_project = parse_body['project']
				expect(response.status).to eq(200) #2
				expect(body_project['teams']).to be_truthy
				expect(body_project['unit']).to be_falsy

				get :show, params: { id: @project.id, includes: 'teams,unit'}
				body_project = parse_body['project']
				expect(response.status).to eq(200) #3
				expect(body_project['teams']).to be_truthy
				expect(body_project['unit']).to be_truthy
			end

			it 'returns the resource full but only the associations ids if ?compact=true' do
				get :show, params: { id: @project.id }
				body_project = parse_body['project']
				expect(response.status).to eq(200)
				expect(body_project).to include('description', 'start_date')
				expect(body_project['teams']).to be_falsy
				expect(body_project['unit']).to be_falsy

				get :show, params: { id: @project.id, includes: 'teams', compact: true}
				body_project = parse_body['project']
				expect(response.status).to eq(200)
				expect(body_project['teams']).to be_truthy
				expect(body_project['teams'].first).to_not include('name', 'enrollment_key')
				expect(body_project['unit']).to be_falsy

				get :show, params: { id: @project.id, includes: 'teams,unit'}
				body_project = parse_body['project']
				expect(response.status).to eq(200)
				expect(body_project['teams']).to be_truthy
				expect(body_project['teams'].first).to include('name', 'enrollment_key')
				expect(body_project['unit']).to be_truthy
				expect(body_project['unit']).to include('code', 'semester')
			end

			it 'strips the * from the includes params' do
				get :show, params: { id: @project.id, includes: 'teams,**' }
				expect(parse_body['project']['teams']).to be_truthy
				expect(parse_body['project']['unit']).to be_falsy
			end

			it 'arbitrary includes associations will be ignored' do
				get :show, params: { id: @project.id, includes: 'teams,*,lecturer,banana' }
				expect(parse_body['project']['teams']).to be_truthy
				expect(parse_body['project']['unit']).to be_falsy
				expect(parse_body['project']['lecturer']).to be_falsy
				expect(parse_body['project']['banana']).to be_falsy
			end

			it 'works for index' do
				get :index, params: { includes: 'unit' }
				expect(response.status).to eq(200)
				expect(parse_body['projects'].first['unit']).to be_truthy
				expect(parse_body['projects'].first['teams']).to be_falsy
			end

			it 'renders empty array if no collection is empty' do
				@unit.projects.destroy_all
				expect(@unit.projects.empty?).to be_truthy
				get :index, params: { unit_id: @unit.id, includes: 'teams' }
				expect(response.status).to eq(204)
				expect(response.body.empty?).to be_truthy
			end

			it 'renders no associations if includes emtpy string?' do
				get :show, params: { id: @project.id, includes: "" }
				expect(parse_body['project']['unit']).to be_falsy
				expect(parse_body['project']['teams']).to be_falsy
			end
		end
	end


end
