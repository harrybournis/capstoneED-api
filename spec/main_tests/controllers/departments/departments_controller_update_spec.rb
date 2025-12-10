require 'rails_helper'

RSpec.describe V1::DepartmentsController, type: :controller do

	describe 'PATCH update' do

		context 'valid' do
			before(:each) do
				@controller = V1::DepartmentsController.new
				@user = FactoryBot.build(:lecturer_with_password).process_new_record
				@user.save
				@user.confirm
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				unit = FactoryBot.create(:unit, lecturer_id: @user.id)
				@department = unit.department
			end

			it 'responds with 200 ok' do
				patch :update, params: { id: @department.id, university: 'different' }
				expect(response.status).to eq(200)
				@department.reload
				expect(@department.university).to eq('different')
			end
		end

		context 'invalid' do

			it 'responds with 401 unauthorized if authentication failed' do
				patch :update, params: { id: 3 }
				expect(response.status).to eq(401)
			end

			it 'responds with 403 forbidden if user is not lecturer' do
				@controller = V1::DepartmentsController.new
				@user = FactoryBot.build(:student_with_password).process_new_record
				@user.save
				@user.confirm
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				@department = FactoryBot.create(:department)

				patch :update, params: { id: @department.id, university: 'different' }
				expect(response.status).to eq(403)
				expect(JSON.parse(response.body)['errors']['base'].first).to include('You must be Lecturer to access this resource')
			end
		end
	end
end
