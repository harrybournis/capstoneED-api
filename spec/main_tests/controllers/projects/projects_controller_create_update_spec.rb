require 'rails_helper'

RSpec.describe V1::ProjectsController, type: :controller do

	describe 'POST create' do

		context 'valid' do

			before(:each) do
				@controller = V1::ProjectsController.new
				@user = FactoryGirl.build(:lecturer_with_units).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				project1 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units[0])
				project2 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units[0])
				project3 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units.last)
				project_irrelevant = FactoryGirl.create(:project)
			end

			it 'responds with 201 created and creates a new Project' do
				parameters = FactoryGirl.attributes_for(:project, unit_id: @user.units[0].id)
				post :create, params: parameters
				expect(status).to eq(201)
				expect(Project.find(parse_body['project']['id']).unit_id).to eq(parameters[:unit_id])
			end

			it 'accepts nested attributes for teams' do
				parameters = FactoryGirl.attributes_for(:project, unit_id: @user.units[0].id).merge(teams_attributes: [{ name: 'New Team1', enrollment_key: 'key' }, { name: 'New Team2', enrollment_key: 'key2' }] )
				expect {
					post :create, params: parameters
				}.to change { Team.count }.by(2)
				expect(status).to eq(201)
				expect(Project.find(parse_body['project']['id']).unit_id).to eq(parameters[:unit_id])
				expect(body['project']['teams'].length).to eq(2)
			end
		end

	end

	describe 'PATCH update' do

			before(:each) do
				@controller = V1::ProjectsController.new
				@user = FactoryGirl.build(:lecturer_with_units).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
				expect(request.headers['X-XSRF-TOKEN']).to be_truthy
				@project1 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units[0])
				@project2 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units[0])
				@project3 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units.last)
				@project_irrelevant = FactoryGirl.create(:project)
			end

			it 'updates params if current user is the owner' do
				date = Date.today + 1.year
				patch :update, params: { id: @user.projects[0].id, end_date: date }
				expect(status).to eq(200)
				expect(parse_body['project']['end_date']).to eq(date.to_formatted_s(:db))
			end

			it 'responds with 403 forbidden if th unit_id does not belong to current user' do
				patch :update, params: { id: @project_irrelevant }
				expect(status).to eq(403)
				expect(parse_body['errors']['base'][0]).to eq("This Project is not associated with the current user")
			end
	end
end
