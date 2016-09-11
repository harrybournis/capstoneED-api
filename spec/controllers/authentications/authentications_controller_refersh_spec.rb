require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::AuthenticationsController POST /refresh', type: :controller do

	context 'valid request' do

		before(:each) do
			@controller = V1::AuthenticationsController.new
			@user = FactoryGirl.build(:user_with_password).process_new_record
			@user.save
			@mock_request = MockRequest.new(valid = true, @user, remember_me = true)
			request.cookies['access-token'] = @mock_request.cookies['access-token']
			request.cookies['refresh-token']= @mock_request.cookies['refresh-token']
			request.headers['X-XSRF-TOKEN'] = @mock_request.headers['X-XSRF-TOKEN']
			expect { @decoded_token = JWTAuth::JWTAuthenticator.decode_token(request.cookies['refresh-token']) }.to_not raise_error
			expect(@decoded_token).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
			@token = FactoryGirl.create(:active_token, device: @decoded_token.first['device'], user: @user, exp: Time.now + 1.day)
			expect(@token.valid?).to be_truthy
		end

		it 'response contains new access-token, new refresh-token cookies, and XSRF-TOKEN in headers' do
			post :refresh
			expect(response.status).to eq(204)
			expect(response.headers).to include('Set-Cookie')
			expect(response.headers['Set-Cookie']).to include('access-token')
			expect(response.headers['Set-Cookie']).to include('refresh-token')
			expect(response.headers).to include('XSRF-TOKEN')
		end

		it 'response returns 200 ok' do
			post :refresh
			expect(response.status).to eq(204)
		end

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
			expect(response.status).to eq(204)
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
			expect { @decoded_token = JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token']) }.to raise_error(JWT::VerificationError, 'Signature verification raised')
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
		end

		it 'returns 401 if refresh token is missing' do
			request.cookies.delete('refresh-token')
			expect(request.cookies).to_not include('refresh-token')
			post :refresh
			expect(response.status).to eq(401)
		end

		it 'returns 401 if refresh token is invalid' do
			post :refresh
			expect(response.status).to eq(401)
		end

		it 'returns 401 if refresh token is revoked' do
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.cookies['refresh-token']= mock_request.cookies['refresh-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			expect { @decoded_token2 = JWTAuth::JWTAuthenticator.decode_token(request.cookies['refresh-token']) }.to_not raise_error
			expect(@decoded_token2).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
			token = FactoryGirl.create(:active_token, device: @decoded_token2.first['device'], user: @user, exp: Time.now + 1.month)
			expect(token.valid?).to be_truthy

			expect(@decoded_token2.first['exp'] >= token.exp.to_i).to_not be_truthy
			post :refresh
			expect(response.status).to eq(401)
		end

		it 'returns 401 if refresh token is valid, but no active token in the database' do
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.cookies['refresh-token']= mock_request.cookies['refresh-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			expect { @decoded_token3 = JWTAuth::JWTAuthenticator.decode_token(request.cookies['refresh-token']) }.to_not raise_error
			expect(@decoded_token3).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy

			expect(ActiveToken.find_by_device(JWTAuth::JWTAuthenticator.decode_token(request.cookies['refresh-token']).first['device'])).to be_falsy
			post :refresh
			expect(response.status).to eq(401)
		end

		it 'does not return two new cookies and XSRF-TOKEN in the headers' do
			post :refresh
			expect(response.status).to eq(401)
			expect(response.headers).to_not include('Set-Cookie')
			expect(response.headers).to_not include('XSRF-TOKEN')
		end

		it 'the valid token remains the same' do
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.cookies['refresh-token']= mock_request.cookies['refresh-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			expect { @decoded_token4 = JWTAuth::JWTAuthenticator.decode_token(request.cookies['refresh-token']) }.to_not raise_error
			expect(@decoded_token4).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
			token = FactoryGirl.create(:active_token, device: @decoded_token4.first['device'], user: @user, exp: Time.now + 1.month)
			expect(token.valid?).to be_truthy

			old_exp = token.exp
			expect(@decoded_token4.first['exp'] >= token.exp.to_i).to_not be_truthy
			post :refresh
			expect(response.status).to eq(401)
			token.reload
			expect(token.exp).to eq(old_exp)
		end
	end
end
