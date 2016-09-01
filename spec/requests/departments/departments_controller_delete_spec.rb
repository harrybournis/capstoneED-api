require 'rails_helper'

RSpec.describe V1::DepartmentsController, type: :request do

	before(:each) { host! 'api.example.com' }

	describe 'DELETE delete' do

		context 'valid' do
			before(:each) do
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				@user.confirm
				post '/v1/sign_in', params: { email: @user.email, password: '12345678' }
				expect(response.status).to eq(200)
				@csrf_token = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
				@department = FactoryGirl.create(:department)
			end

			it 'responds with 200 ok' do
				delete "/v1/departments/#{@department.id}", params: { id: @department.id }, headers: { 'X-XSRF-TOKEN' => @csrf_token }
				expect(response.status).to eq(204)
				expect(Department.exists?(@department.id)).to be_falsy
			end
		end

		context 'invalid' do

			it 'responds with 401 unauthorized if authentication failed' do
				delete '/v1/departments/:id', params: { id: 3 }, headers: { 'X-XSRF-TOKEN' => 'iewn8943buyirleah' }
				expect(response.status).to eq(401)
			end

			it 'responds with 403 forbidden if user is not lecturer' do
				@user = FactoryGirl.build(:student_with_password).process_new_record
				@user.save
				@user.confirm
				post '/v1/sign_in', params: { email: @user.email, password: '12345678' }
				expect(response.status).to eq(200)
				@csrf_token = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
				@department = FactoryGirl.create(:department)

				delete '/v1/departments/:id', params: { id: @department.id }, headers: { 'X-XSRF-TOKEN' => @csrf_token }
				expect(response.status).to eq(403)
				expect(JSON.parse(response.body)['errors']['base'].first).to eq('You must be Lecturer to access this resource')
			end
		end
	end
end
