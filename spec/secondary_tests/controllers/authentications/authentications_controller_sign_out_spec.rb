require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator
module V1
RSpec.describe 'V1::AuthenticationsController POST /sign_out', type: :controller do

	context 'valid request: ' do

		before(:each) do
			@controller = V1::AuthenticationsController.new
			@user = FactoryBot.build(:user_with_password).process_new_record
			@user.save
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])
			expect(decoded_token).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
			@token = FactoryBot.create(:active_token, device: decoded_token.first['device'], user: @user, exp: Time.now + 1.week)
			expect(@token.valid?).to be_truthy
		end

		it 'should delete the active token for this device' do
			expect {
				post :sign_out
			}.to change { ActiveToken.count }.by(-1)
			expect(ActiveToken.exists?(@token.id)).to be_falsy
			expect(response.status).to eq(204)
		end

		it 'returns 204 no content', { docs?: true } do
			post :sign_out
			expect(response.status).to eq(204)
		end

		it 'deletes the access-token and the refresh-token' do
			post :sign_out
			expect(response.status).to eq(204)
			expect(response.cookies['access-token']).to be_falsy
			expect(response.cookies['refresh-token']).to be_falsy
		end
	end

	context 'invalid request: ' do

		before(:each) do
			@controller = V1::AuthenticationsController.new
			@user = FactoryBot.build(:user_with_password).process_new_record
			@user.save
			mock_request = MockRequest.new(valid = false, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			expect { JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token']) }.to raise_error(JWT::VerificationError, 'Signature verification raised')
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
		end

		it 'should NOT delete the active token' do
			expect { post :sign_out }.to_not change { ActiveToken.count }
			expect(response.status).to eq(401)
		end

		it 'response does not delete access-token and refresh-token cookies' do
			post :sign_out
			expect(response.status).to eq(401)
			expect(response.cookies.include?('access-token')).to be_falsy
			expect(response.cookies.include?('refresh-token')).to be_falsy
		end

		it 'should return 401 unauthorized' do
			post :sign_out
			expect(response.status).to eq(401)
		end
	end
end
end
