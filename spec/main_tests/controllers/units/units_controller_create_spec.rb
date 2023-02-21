require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::UnitsController, type: :controller do

	describe 'POST create' do

		context 'valid request' do

			before(:all) do
				@user = FactoryBot.build(:lecturer_with_password).process_new_record
				@user.save
			end

			before(:each) do
				@controller = V1::UnitsController.new
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			end

			it 'creates a department with nested attributes', { docs?: true } do
				parameters = FactoryBot.attributes_for(:unit).merge(department_attributes: { name: 'departmentname', university: 'university' })
				expect {
					post :create, params: parameters
				}.to change { Department.all.count }.by(1)
				expect(response.status).to eq(201)
				expect(Department.last.name).to eq('departmentname')
				expect(Unit.last.lecturer).to eq(@user)
			end

			it 'assigns an already created department', { docs?: true } do
				department = FactoryBot.create(:department)
				parameters = FactoryBot.attributes_for(:unit, department_id: department.id)
				expect {
					post :create, params: parameters
				}.to_not change { Department.all.count }
				expect(response.status).to eq(201)
				expect(Unit.last.department).to eq(department)
				expect(Unit.last.lecturer).to eq(@user)
			end

			it 'if both then department_id takes precedence' do
				department = FactoryBot.create(:department)
				parameters = FactoryBot.attributes_for(:unit, department_id: department.id).merge(department_attributes: { name: 'departmentname', university: 'university' })
				expect {
					post :create, params: parameters
				}.to_not change { Department.all.count }
				expect(response.status).to eq(201)
				expect(Unit.last.department).to eq(department)
				expect(Unit.last.lecturer).to eq(@user)
			end

			it 'if only department present' do
				parameters = FactoryBot.attributes_for(:unit)
				expect {
					post :create, params: parameters
				}.to_not change { Department.all.count }
				expect(response.status).to eq(422)
				expect(errors['department'][1]).to include('must exist. Either provide a department_id, or deparment_attributes in order to create a new Department')
			end
		end

		context 'invalid request' do

			it 'must be a lecturer to create a Unit' do
				@controller = V1::UnitsController.new
				@user = FactoryBot.build(:student_with_password).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				department = FactoryBot.create(:department)
				random_lecturer = FactoryBot.create(:lecturer)
				post :create, params: FactoryBot.attributes_for(:unit, department_id: department.id)
				expect(response.status).to eq(403)
				expect(parse_body['errors']['base'].first).to include('You must be Lecturer to access this resource')
			end

			it 'errors in nested attributes', { docs?: true } do
				@controller = V1::UnitsController.new
				@user = FactoryBot.build(:lecturer_with_password).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				parameters = FactoryBot.attributes_for(:unit).merge(department_attributes: { name: 1 })
				expect {
					post :create, params: parameters
				}.to_not change { Unit.all.count }
				expect(response.status).to eq(422)
				expect(parse_body['errors']['department.university'].first).to eq("can't be blank")
			end
		end
	end
end
