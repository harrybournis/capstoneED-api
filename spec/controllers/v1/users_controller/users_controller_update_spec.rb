require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::UsersController PUT /update', type: :controller do

	context 'valid request' do

		before(:each) do
			new_en = FactoryGirl.create(:user)
			mock_request = MockRequest.new(valid = true, new_en)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
		end

		describe 'PUT update' do
			it "replaces user's first_name with the first_name in the params"
			it 'does not change the number of users in the database'
			it 'returns 200 ok with the updated user'
			it 'requires the old password to update the password'
		end

	end

	context 'invalid request' do

		describe 'PUT update' do
			it 'ignores updates to the provider field'
			it 'returns 401 if authentication problem'
			it 'returns 422 unprocessable_entity if email format wrong'
			it 'returns 422 unprocessable_entity if password confirmation does not match'
			it 'returns 422 unprocessable_entity if old password is invalid'
		end
	end
end
