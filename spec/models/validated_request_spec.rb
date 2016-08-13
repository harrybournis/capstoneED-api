require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth

RSpec.describe JWTAuth::ValidatedRequest, type: :model do

	let(:user) { FactoryGirl.create(:user) }
	let(:device) { SecureRandom.base64(32) }
	let(:request) { MockRequest.new(true, user, device) }

	context 'valid request' do

		describe 'access request' do
			it 'should return the same values as the request passed to it' do
				user = FactoryGirl.create(:user)
				device = SecureRandom.base64(32)
				request = MockRequest.new(true, user, device)
				validated_request = JWTAuth::JWTAuthenticator.valid_access_request(request)
				expect(validated_request).to be_truthy

				expect(request.headers['X-XSRF-TOKEN']).to eq(validated_request.csrf_token)
				expect(request.cookies["access-token"]).to eq(validated_request.access_token)
			end
		end

		describe 'refresh request' do
			it 'should return the same values as the request passed to it' do
				user = FactoryGirl.create(:user)
				device = SecureRandom.base64(32)
				request = MockRequest.new(true, user, device)
				validated_request = JWTAuth::JWTAuthenticator.valid_refresh_request(request)
				expect(validated_request).to be_truthy

				expect(request.cookies["refresh-token"]).to eq(validated_request.refresh_token)
			end
		end

	end

	context 'invalid request' do

		it 'access request should return false without token' do
			user = FactoryGirl.create(:user)
			device = SecureRandom.base64(32)
			request = MockRequest.new(true, user, device)
			request.cookies.delete('access-token')
			expect(JWTAuth::JWTAuthenticator.valid_access_request(request)).to be_falsy
		end

		it 'access request should return false without csrf token in the headers' do
			user = FactoryGirl.create(:user)
			device = SecureRandom.base64(32)
			request = MockRequest.new(true, user, device)
			request.headers.delete('X-XSRF-TOKEN')
			expect(JWTAuth::JWTAuthenticator.valid_access_request(request)).to be_falsy
		end

		it 'refresh request should return false' do
			user = FactoryGirl.create(:user)
			device = SecureRandom.base64(32)
			request = MockRequest.new(true, user, device)
			request.cookies.delete('refresh-token')
			expect(JWTAuth::JWTAuthenticator.valid_refresh_request(request)).to be_falsy
		end
	end
end
