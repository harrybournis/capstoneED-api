require 'rails_helper'

RSpec.describe V1::ProjectsController, type: :controller do

	describe 'GET index' do

		before(:all) do
			@controller = V1::ProjectsController.new
			@user = FactoryGirl.build(:lecturer_with_units).process_new_record
			@user.save
			project1 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units.first)
			project2 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units.first)
			project3 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units.last)
			project_irrelevant = FactoryGirl.create(:project)
		end

		before(:each) do
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		it 'returns all the projects for the current user if no unit_id is provided' do
			get :index
			expect(response.status).to eq(200)
			expect(parse_body['projects'].length).to eq(3)
		end

		it 'returns all the projects for the current unit if unit_id is provided and belongs to current user' do
			get :index_with_unit, params: { unit_id: @user.units.first.id }
			expect(response.status).to eq(200)
			expect(parse_body['projects'].length).to eq(2)
		end

		it 'responds with 403 forbidden if unit is does not belong to current user' do
			unit = FactoryGirl.create(:unit)
			get :index_with_unit, params: { unit_id: unit.id }
			expect(response.status).to eq(403)
		end

		it 'responds with 403 forbidden if the user is a student and unit_id is present in the params' do
			@user = FactoryGirl.build(:student_with_password).process_new_record
			@user.save
			unit = FactoryGirl.create(:unit)
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			get :index_with_unit, params: { unit_id: unit.id }
			expect(status).to eq(403)
			expect(body['errors']['base'][0]).to eq('You must be Lecturer to access this resource')
		end
	end

	describe 'GET show' do

		context 'lecturer' do

			before(:all) do
				@controller = V1::ProjectsController.new
				@user_w = FactoryGirl.build(:lecturer_with_units).process_new_record
				@user_w.save
				@user_w.confirm
				@project1 = FactoryGirl.create(:project, lecturer: @user_w, unit: @user_w.units.first)
				@project2 = FactoryGirl.create(:project, lecturer: @user_w, unit: @user_w.units.first)
				@project3 = FactoryGirl.create(:project, lecturer: @user_w, unit: @user_w.units.last)
				@project_irrelevant = FactoryGirl.create(:project)
			end

			before(:each) do
				mock_request = MockRequest.new(valid = true, @user_w)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			end

			it 'returns project if it belongs to current_user' do
				get :show, params: { id: @project3.id, includes: 'unit' }
				expect(response.status).to eq(200)
				expect(parse_body['project']['id']).to eq(@project3.id)
			end

			it 'responds with 403 forbidden if th unit_id does not belong to current user' do
				get :show, params: { id: @project_irrelevant }
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to eq("This Project is not associated with the current user")
			end
		end
	end

	describe 'DELETE destroy' do

		context 'lecturer' do

			before(:all) do
				@controller = V1::ProjectsController.new
				@user = FactoryGirl.build(:lecturer_with_units).process_new_record
				@user.save
				@project1 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units.first)
				@project2 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units.first)
				@project3 = FactoryGirl.create(:project, lecturer: @user, unit: @user.units.last)
				@project_irrelevant = FactoryGirl.create(:project)
			end

			before(:each) do
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			end

			it 'returns project if it belongs to current_user' do
				expect {
					delete :destroy, params: { id: @project3.id }
				}.to change { Project.all.length }.by(-1)
				expect(response.status).to eq(204)
			end

			it 'responds with 403 forbidden if th unit_id does not belong to current user' do
				expect {
					delete :destroy, params: { id: @project_irrelevant }
				}.to_not change { Project.all.length }
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to eq("This Project is not associated with the current user")
			end
		end

		context 'student' do
			it 'only the lecturer who created the project can destroy it' do
				@controller = V1::ProjectsController.new
				@user = FactoryGirl.build(:student_with_password).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
				expect(request.headers['X-XSRF-TOKEN']).to be_truthy
				project = FactoryGirl.create(:project)

				expect{
					delete :destroy, params: { id: project.id }
				}.to_not change { Project.all.length }
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to eq("You must be Lecturer to access this resource")
			end
		end
	end
end
