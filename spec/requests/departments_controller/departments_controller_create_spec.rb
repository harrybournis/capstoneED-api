require 'rails_helper'

RSpec.describe V1::DepartmentsController, type: :request do

	describe 'POST create' do

		context 'valid' do
			before(:each) do
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				@user.confirm
				post '/v1/sign_in', params: { email: @user.email, password: '12345678' }
				expect(response.status).to eq(200)
				@csrf_token = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
			end

			it 'responds with 201 created' do
				post '/v1/departments', params: FactoryGirl.attributes_for(:department), headers: { 'X-XSRF-TOKEN' => @csrf_token }
				expect(response.status).to eq(201)
			end

			it 'creates a new department in the database' do
				expect {
					post '/v1/departments', params: FactoryGirl.attributes_for(:department), headers: { 'X-XSRF-TOKEN' => @csrf_token }
				}.to change { Department.all.count }.by(1)
			end
		end

		context 'invalid' do

			it 'responds with 401 unauthorized if authentication failed' do
				post '/v1/departments', params: FactoryGirl.attributes_for(:department), headers: { 'X-XSRF-TOKEN' => 'iewn8943buyirleah' }
				expect(response.status).to eq(401)
			end

			it 'responds with 403 forbidden if user is not lecturer' do
				@user = FactoryGirl.build(:student_with_password).process_new_record
				@user.save
				@user.confirm
				post '/v1/sign_in', params: { email: @user.email, password: '12345678' }
				expect(response.status).to eq(200)
				@csrf_token = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']

				post '/v1/departments', params: FactoryGirl.attributes_for(:department), headers: { 'X-XSRF-TOKEN' => @csrf_token }
				expect(response.status).to eq(403)
				expect(JSON.parse(response.body)['errors']['type'].first).to eq('must be Lecturer')
			end

			it 'responds with 422 unprocessable entity if validation fail' do
				@user = FactoryGirl.build(:lecturer_with_password).process_new_record
				@user.save
				@user.confirm
				post '/v1/sign_in', params: { email: @user.email, password: '12345678' }
				expect(response.status).to eq(200)
				@csrf_token = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']

				post '/v1/departments', params: { department: 'dkdkdk'}, headers: { 'X-XSRF-TOKEN' => @csrf_token }
				expect(response.status).to eq(422)
				expect(JSON.parse(response.body)['errors']['name'].first).to eq("can't be blank")
			end
		end
	end
end
