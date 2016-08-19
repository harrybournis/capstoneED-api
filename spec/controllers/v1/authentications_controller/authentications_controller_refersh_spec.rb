require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::AuthenticationsController POST /refresh', type: :controller do

	context 'valid request' do

		before(:each) do
			@controller = V1::AuthenticationsController.new
			@user = FactoryGirl.build(:user_with_password).process_new_record
			@user.save
			@mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = @mock_request.cookies['access-token']
			request.cookies['refresh-token']= @mock_request.cookies['refresh-token']
			request.headers['X-XSRF-TOKEN'] = @mock_request.headers['X-XSRF-TOKEN']
			expect { @decoded_token = JWTAuth::JWTAuthenticator.decode_token(request.cookies['refresh-token']) }.to_not raise_error
			expect(@decoded_token).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
			@token = FactoryGirl.create(:active_token, device: @decoded_token.first['device'], user: @user, exp: Time.now + 1.day)
			expect(@token.valid?).to be_truthy
		end

		it 'contains a refresh_token in a cookie' do
			post :refresh
			expect(response.status).to eq(200)
			expect(cookies['refresh-token']).to be_truthy
			expect(JWTAuth::JWTAuthenticator.decode_token(cookies['refresh-token']).first['exp']).to_not eq(@decoded_token.first['exp'])
			binding.pry
		end

		it 'response returns 200 ok' do
			post :refresh
			expect(response.status).to eq(200)
		end

		it 'response contains new access-token, new refresh-token cookies, and XSRF-TOKEN in headers'

		it 'active token is updated with the new expiration date' do
			old_exp = @token.exp
			post :refresh
			@token.reload
			expect(@token.exp).to_not eq(old_exp)
			expect(@token.exp).to be > old_exp
		end

		it 'refresh token is not revoked' do
			expect(@decoded_token.first['exp'] >= @token.exp.to_i).to be_truthy
			post :refresh
			expect(response.status).to eq(200)
		end
	end

	context 'invalid request' do
		before(:each) do
			@controller = V1::AuthenticationsController.new
			@user = FactoryGirl.build(:user_with_password).process_new_record
			@user.save
			mock_request = MockRequest.new(valid = false, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.cookies['refresh-token']= mock_request.cookies['refresh-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			expect { JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token']) }.to raise_error(JWT::VerificationError, 'Signature verification raised')
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
		end

		it 'returns 401 if refresh token is missing'

		it 'returns 401 if refresh token is invalid' do
			post :refresh
			expect(response.status).to eq(401)
		end

		it 'returns 401 if refresh token is revoked'
		it 'returns 401 if refresh token is valid, but no active token in the database'
		it 'does not return two new cookies and XSRF-TOKEN in the headers'
		it 'the valid token remains the same'
	end
end
