require 'rails_helper'

RSpec.describe V1::UnitsController, type: :request do

	describe 'POST create' do

		context 'valid request' do

			before(:each) do
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				@user.confirm
				post '/v1/sign_in', params: { email: @user.email, password: '12345678' }
				expect(response.status).to eq(200)
				@csrf_token = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
			end

			it 'creates a department with nested attributes' do
				parameters = FactoryGirl.attributes_for(:unit).merge(department_attributes: { name: 'departmentname', university: 'university' })
				expect {
					post "/v1/lecturers/#{@user.id}/units", params: parameters, headers: { 'X-XSRF-TOKEN' => @csrf_token }
				}.to change { Department.all.count }.by(1)
				expect(response.status).to eq(201)
				expect(Department.last.name).to eq('departmentname')
			end

			it 'assigns an already created department' do
				department = FactoryGirl.create(:department)
				parameters = FactoryGirl.attributes_for(:unit, department_id: department.id)
				expect {
					post "/v1/lecturers/#{@user.id}/units", params: parameters, headers: { 'X-XSRF-TOKEN' => @csrf_token }
				}.to_not change { Department.all.count }
				expect(response.status).to eq(201)
				expect(Unit.last.department).to eq(department)
			end
		end

		context 'invalid request' do

			it 'must be a lecturer to create a Unit' do
				@user = FactoryGirl.build(:student_with_password).process_new_record
				@user.save
				@user.confirm
				post '/v1/sign_in', params: { email: @user.email, password: '12345678' }
				expect(response.status).to eq(200)
				@csrf_token = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']

				department = FactoryGirl.create(:department)
				random_lecturer = FactoryGirl.create(:lecturer)
				post "/v1/lecturers/#{random_lecturer.id}/units", params: FactoryGirl.attributes_for(:unit, department_id: department.id), headers: { 'X-XSRF-TOKEN' => @csrf_token }
				expect(response.status).to eq(403)
				expect(JSON.parse(response.body)['errors']['type'].first).to eq('must be Lecturer')
			end
		end
	end
end
