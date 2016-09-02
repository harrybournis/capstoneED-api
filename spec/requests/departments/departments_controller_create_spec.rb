require 'rails_helper'

RSpec.describe V1::DepartmentsController, type: :controller do

	describe 'POST create' do

		context 'valid' do
			before(:each) do
				@controller = V1::DepartmentsController.new
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				@user.confirm
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			end

			it 'responds with 201 created' do
				expect {
					post :create, params: FactoryGirl.attributes_for(:department)
				}.to change { Department.all.count }.by(1)
				expect(response.status).to eq(201)
			end
		end

		context 'invalid' do

			it 'responds with 401 unauthorized if authentication failed' do
				post :create, params: FactoryGirl.attributes_for(:department)
				expect(response.status).to eq(401)
			end

			it 'responds with 403 forbidden if user is not lecturer' do
				@controller = V1::DepartmentsController.new
				@user = FactoryGirl.build(:student_with_password).process_new_record
				@user.save
				@user.confirm
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				post :create, params: FactoryGirl.attributes_for(:department)
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to eq('You must be Lecturer to access this resource')
			end

			it 'responds with 422 unprocessable entity if validation fail' do
				@controller = V1::DepartmentsController.new
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				@user.confirm
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				post :create, params: { department: 'dkdkdk'}
				expect(response.status).to eq(422)
				expect(parse_body['errors']['name'].first).to eq("can't be blank")
			end

			it 'create with id 5' do
				@controller = V1::DepartmentsController.new
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				@user.confirm
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				post :create, params: { id: 5, name: 'Department of Potatoes', university: 'Idaho' }
				expect(response.status).to eq(201) #1
				expect(Department.find(5).id).to eq(5)

				post :create, params: { id: 5, name: 'Department of Potatoes', university: 'Idaho' }
				expect(response.status).to eq(422)# 2
				expect(parse_body['errors']['id'].first).to eq('has already been taken')
			end
		end
	end
end
