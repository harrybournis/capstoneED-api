require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::UnitsController, type: :controller do

	describe 'POST create' do

		context 'valid request' do

			before(:each) do
				@controller = V1::UnitsController.new
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
				expect(request.headers['X-XSRF-TOKEN']).to be_truthy
			end

			it 'creates a department with nested attributes' do
				parameters = FactoryGirl.attributes_for(:unit).merge(department_attributes: { name: 'departmentname', university: 'university' })
				expect {
					post :create, params: parameters
				}.to change { Department.all.count }.by(1)
				expect(response.status).to eq(201)
				expect(Department.last.name).to eq('departmentname')
				expect(Unit.last.lecturer).to eq(@user)
			end

			it 'assigns an already created department' do
				department = FactoryGirl.create(:department)
				parameters = FactoryGirl.attributes_for(:unit, department_id: department.id)
				expect {
					post :create, params: parameters
				}.to_not change { Department.all.count }
				expect(response.status).to eq(201)
				expect(Unit.last.department).to eq(department)
				expect(Unit.last.lecturer).to eq(@user)
			end

			it 'what if both?' do
				department = FactoryGirl.create(:department)
				parameters = FactoryGirl.attributes_for(:unit, department_id: department.id).merge(department_attributes: { name: 'departmentname', university: 'university' })
				expect {
					post :create, params: parameters
				}.to_not change { Department.all.count }
				expect(response.status).to eq(201)
				expect(Unit.last.department).to eq(department)
				expect(Unit.last.lecturer).to eq(@user)
			end
		end

		context 'invalid request' do

			it 'must be a lecturer to create a Unit' do
				@controller = V1::UnitsController.new
				@user = FactoryGirl.build(:student_with_password).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
				expect(request.headers['X-XSRF-TOKEN']).to be_truthy

				department = FactoryGirl.create(:department)
				random_lecturer = FactoryGirl.create(:lecturer)
				post :create, params: FactoryGirl.attributes_for(:unit, department_id: department.id)
				expect(response.status).to eq(403)
				expect(parse_body['errors']['type'].first).to eq('must be Lecturer')
			end

			it 'errors in nested attributes' do
				@controller = V1::UnitsController.new
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
				expect(request.headers['X-XSRF-TOKEN']).to be_truthy

				parameters = FactoryGirl.attributes_for(:unit).merge(department_attributes: { name: 1 })
				expect {
					post :create, params: parameters
				}.to_not change { Unit.all.count }
				expect(response.status).to eq(422)
				expect(parse_body['errors']['department.university'].first).to eq("can't be blank")
			end
		end
	end
end
