require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::AuthenticationsController POST /sign_in_email', type: :controller do

	before(:each) do
		@controller = V1::AuthenticationsController.new
		@user = FactoryGirl.build(:lecturer_with_password).process_new_record
		@user.save
	end

	context 'valid request' do

		it 'password is valid' do
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(assigns(:user).valid_password?('12345678')).to be_truthy
		end

		it 'response contains the user', { docs?: true } do
			@user.confirm
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(parse_body).to include('user')
			expect(parse_body['user']['id']).to eq(@user.id)
		end

		it 'returns 200 ok' do
			@user.confirm
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(response.status).to eq(200)
		end

		it 'response contains XSRF-TOKEN headers' do
			@user.confirm
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(response.headers['XSRF-TOKEN']).to be_truthy
		end

		it 'response contains access-token, refresh-token in cookies' do
			@user.confirm
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(cookies['access-token']).to be_truthy
			expect(cookies['refresh-token']).to be_truthy
		end

		it 'refresh token has no expirations date if remember_me is true' do
			@user.confirm
			post :sign_in_email, params: { email: @user.email, password: '12345678', remember_me: 1 }
			expect(cookies['access-token']).to be_truthy
			expect(cookies['refresh-token']).to be_truthy
			decoded = JWTAuth::JWTAuthenticator.decode_token(cookies['refresh-token'])
			expect(decoded.first["remember_me"]).to be_truthy
		end
	end

	context 'invalid request' do
		it 'returns 400 bad request' do
			post :sign_in_email
			expect(response.status).to eq(401)
			expect(parse_body['errors']['base'].first).to eq('Invalid Login Credentials')
			expect(parse_body['errors']['email']).to be_falsy
		end

		it 'email does not exist in database' do
			@user.confirm
			post :sign_in_email, params: { email: 'wrong@emaildoesnotexist.com', password: '12345678' }
			expect(response.status).to eq(401)
			expect(parse_body['errors']['base'].first).to eq('Invalid Login Credentials')
			expect(User.find_by_email('wrong@emaildoesnotexist.com')).to be_falsy
		end

		it 'email exists, password does not match with email', { docs?: true } do
			@user.confirm
			post :sign_in_email, params: { email: @user.email, password: 'wrongpassword' }
			expect(response.status).to eq(401)
			expect(parse_body['errors']['base'].first).to eq('Invalid Login Credentials')
			expect(User.find_by_email(@user.email).valid_password?('wrongpassword')).to be_falsy
		end

		it 'user is unconfirmed' do
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(response.status).to eq(401)
			expect(parse_body['errors']['email'].first).to eq('is unconfirmed')
			expect(User.find_by_email(@user.email).confirmed_at).to be_falsy
		end

		it 'remember_me is not 0 or 1', { docs?: true } do
			post :sign_in_email, params: { email: @user.email, password: '12345678', remember_me: 'true' }
			expect(response.status).to eq(401)
			expect(parse_body['errors']['base'].first).to eq("remember_me must be either '0' or '1'. Received value: true")
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

		it 'returns 401 if valid request but user is unconfirmed', { docs?: true } do
			post :sign_in_email, params: { email: @user.email, password: '12345678' }
			expect(response.status).to eq(401)
			expect(parse_body['errors']['email'].first).to eq('is unconfirmed')
		end
	end
end
