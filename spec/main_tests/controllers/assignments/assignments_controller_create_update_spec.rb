require 'rails_helper'

RSpec.describe V1::AssignmentsController, type: :controller do

	describe 'POST create' do

		context 'valid' do

			before(:each) do
				@controller = V1::AssignmentsController.new
				@user = FactoryGirl.build(:lecturer_with_units).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				assignment1 = FactoryGirl.create(:assignment, lecturer: @user, unit: @user.units[0])
				assignment2 = FactoryGirl.create(:assignment, lecturer: @user, unit: @user.units[0])
				assignment3 = FactoryGirl.create(:assignment, lecturer: @user, unit: @user.units.last)
				assignment_irrelevant = FactoryGirl.create(:assignment)
			end

			it 'responds with 201 created and creates a new Assignment', { docs?: true } do
				parameters = FactoryGirl.attributes_for(:assignment, unit_id: @user.units[0].id)
				post :create, params: parameters
				expect(status).to eq(201)
				expect(Assignment.find(parse_body['assignment']['id']).unit_id).to eq(parameters[:unit_id])
			end

			it 'accepts nested attributes for projects', { docs?: true } do
				parameters = FactoryGirl.attributes_for(:assignment, unit_id: @user.units[0].id).merge(projects_attributes: [{ project_name: 'New Project1', team_name: 'persons', description: 'dddd', enrollment_key: 'key' }, { project_name: 'New Project2', team_name: 'persons2', description: 'descr', enrollment_key: 'key2' }] )
				expect {
					post :create, params: parameters
				}.to change { Project.count }.by(2)
				expect(status).to eq(201)
				expect(Assignment.find(parse_body['assignment']['id']).unit_id).to eq(parameters[:unit_id])
				expect(body['assignment']['projects'].length).to eq(2)
			end

			it 'accepts nested attributes for game_settings', { docs?: true } do
				points = 86
				parameters = FactoryGirl.attributes_for(:assignment, unit_id: @user.units[0].id).merge(game_setting_attributes: attributes_for(:game_setting).except(:assignment_id).merge(points_log: points) )

				expect {
					post :create, params: parameters
				}.to change { GameSetting.count }.by(1)

				expect(status).to eq(201)
				expect(Assignment.find(body['assignment']['id']).game_setting.points_log).to eq points
			end

			it 'accepts nested attributes for iterations', { docs?: true } do
				iterations = []
				2.times { iterations << attributes_for(:iteration).except(:assignment_id) }
				parameters = FactoryGirl.attributes_for(:assignment, unit_id: @user.units[0].id).merge(iterations_attributes: iterations )

				expect {
					post :create, params: parameters
				}.to change { Iteration.count }.by(2)

				expect(status).to eq(201)
			end

			it 'accepts nested attributes for projects without team_names, and names them accordingly' do
				parameters = FactoryGirl.attributes_for(:assignment, unit_id: @user.units[0].id).merge(projects_attributes: [{ project_name: 'New Project1', description: 'dddd', enrollment_key: 'key' }, { project_name: 'New Project2', description: 'descr', enrollment_key: 'key2' }] )
				expect {
					post :create, params: parameters
				}.to change { Project.count }.by(2)

				expect(status).to eq(201)
				body['assignment']['projects'].each do |project|
					if project['project_name'] == "New Project1"
						expect(project['team_name']).to eq('Team 1')
					elsif project['project_name'] == "New Project2"
						expect(project['team_name']).to eq('Team 2')
					end
				end
			end

			it 'shows errors for projects', { docs?: true } do
				parameters = FactoryGirl.attributes_for(:assignment, unit_id: @user.units[0].id).merge(projects_attributes: [{ project_name: 'New Project1', description: 'dddd', enrollment_key: 'key' }, { team_name: 'persons2', description: 'descr', enrollment_key: 'key2' }] )
				expect {
					post :create, params: parameters
				}.to change { Project.count }.by(0)
				expect(status).to eq(422)
				expect(errors['projects.project_name'][0]).to include "can't be blank"
			end
		end

	end

	describe 'PATCH update' do

			before(:each) do
				@controller = V1::AssignmentsController.new
				@user = FactoryGirl.build(:lecturer_with_units).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
				expect(request.headers['X-XSRF-TOKEN']).to be_truthy
				@assignment1 = FactoryGirl.create(:assignment, lecturer: @user, unit: @user.units[0])
				@assignment2 = FactoryGirl.create(:assignment, lecturer: @user, unit: @user.units[0])
				@assignment3 = FactoryGirl.create(:assignment, lecturer: @user, unit: @user.units.last)
				@assignment_irrelevant = FactoryGirl.create(:assignment)
			end

			it 'updates params if current user is the owner', { docs?: true } do
				patch :update, params: { id: @user.assignments[0].id, name: 'new name'}
				expect(status).to eq(200)
				expect(parse_body['assignment']['name']).to eq('new name')
			end

			it 'responds with 403 forbidden if th unit_id does not belong to current user' do
				patch :update, params: { id: @assignment_irrelevant }
				expect(status).to eq(403)
				expect(parse_body['errors']['base'][0]).to eq("This Assignment is not associated with the current user")
			end
	end
end
