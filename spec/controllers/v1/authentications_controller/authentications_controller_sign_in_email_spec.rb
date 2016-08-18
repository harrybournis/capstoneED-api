require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::AuthenticationsController POST /sign_in_email', type: :controller do

	before(:each) do
		@controller = V1::AuthenticationsController.new
		@user = FactoryGirl.build(:user_with_password).process_new_record
		@user.save
	end

	context 'valid request' do

		it 'password is valid' do
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(assigns(:user).valid_password?('12345678')).to be_truthy
		end

		it 'response contains the user' do
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			res_body = JSON.parse(response.body)
			expect(res_body).to include('user')
			expect(res_body['user']['id']).to eq(@user.id)
		end

		it 'returns 200 ok' do
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(response.status).to eq(200)
		end

		it 'response contains XSRF-TOKEN headers' do
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(response.headers['XSRF-TOKEN']).to be_truthy
		end
		it 'response contains access-token, refresh-token in cookies' do
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(cookies['access-token']).to be_truthy
			expect(cookies['refresh-token']).to be_truthy
		end
	end

	context 'invalid request' do
		it 'returns 401 unauthorized' do
			post :sign_in_email
			expect(response.status).to eq(401)
		end

		it 'email does not exist' do
			post :sign_in_email, params: { email: 'wrong@emaildoesnotexist.com', password: '12345678' }
			expect(response.status).to eq(401)
			expect(User.find_by_email('wrong@email.com')).to be_falsy
		end

		it 'email exists, password does not match with email' do
			post :sign_in_email, params: { email: @user.email, password: 'wrongpassword' }
			expect(response.status).to eq(401)
			expect(User.find_by_email(@user.email).valid_password?('wrongpassword')).to be_falsy
		end

		it 'response does NOT contain XSRF-TOKEN' do
			post :sign_in_email, params: { email: @user.email, password: 'wrongpassword' }
			expect(response.status).to eq(401)
			expect(response.headers['XSRF-TOKEN']).to be_falsy
		end

		it 'response does NOT contain two cookies' do
			post :sign_in_email, params: { email: 'wrong@email.com', password: '12345678' }
			expect(response.status).to eq(401)
			expect(cookies['access-token']).to be_falsy
			expect(cookies['refresh-token']).to be_falsy
		end

		it 'response does NOT contain user' do
			post :sign_in_email, params: { email: 'wronguser', password: 'wrongpassword' }
			expect(response.status).to eq(401)
			expect(response.body).to be_empty
		end
	end
end
