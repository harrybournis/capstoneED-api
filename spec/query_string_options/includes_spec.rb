require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe 'Iincludes', type: :controller do

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
			it 'returns teams if ?includes=teams' do
				@controller = V1::ProjectsController.new
				unit = FactoryGirl.create(:unit, lecturer: @lecturer)
				project = FactoryGirl.create(:project_with_teams, unit: unit, lecturer: @lecturer)
				expect(project.teams.size).to eq(2)

				get :show, params: { id: project.id }
				puts parse_body
				expect(response.status).to eq(200)
				puts parse_body
				expect(parse_body['project']['teams']).to be_falsy

				get :show, params: { id: project.id, includes: 'teams,unit' }
				puts ""
				puts parse_body
				expect(response.status).to eq(200)
				expect(parse_body['project']['teams']).to be_truthy
			end
		end
	end

end
