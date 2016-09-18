require 'rails_helper'

RSpec.describe V1::DepartmentsController, type: :controller do

	describe 'DELETE delete' do

		context 'valid' do
			before(:each) do
				@controller = V1::DepartmentsController.new
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				@user.confirm
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				unit = FactoryGirl.create(:unit, lecturer_id: @user.id)
				@department = unit.department
			end

			it 'responds with 200 ok' do
				delete :destroy, params: { id: @department.id }
				expect(status).to eq(204)
				expect(Department.exists?(@department.id)).to be_falsy
			end
		end

		context 'invalid' do

			it 'responds with 401 unauthorized if authentication failed' do
				delete :destroy, params: { id: 3 }
				expect(status).to eq(401)
			end

			it 'responds with 403 forbidden if user is not lecturer' do
				@controller = V1::DepartmentsController.new
				@user = FactoryGirl.build(:student_with_password).process_new_record
				@user.save
				@user.confirm
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				@department = FactoryGirl.create(:department)

				delete :destroy, params: { id: @department.id }
				expect(status).to eq(403)
				expect(errors['base'].first).to include('You must be Lecturer to access this resource')
			end

			it 'responds with 403 forbidden if current user is not associated with department' do
				@controller = V1::DepartmentsController.new
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				@user.confirm
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				@irrelevant_department = FactoryGirl.create(:department)

				delete :destroy, params: { id: @irrelevant_department.id }
				expect(status).to eq(403)
				expect(errors['base'].first).to include('not associated')
			end
		end
	end
end
