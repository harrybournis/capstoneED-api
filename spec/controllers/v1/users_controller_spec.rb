require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do

	context 'valid request' do

		before(:each) do
			mock_request = MockRequest.new(valid = true)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			expect(JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
		end

		describe 'GET index' do
			it 'should return all users' do
				FactoryGirl.create(:user)
				get :index
				users = JSON.parse(response.body)
				expect(users).to be_truthy
				expect(users['users'].size).to eq(User.all.size)
				expect(response.status).to eq(200)
			end
		end

	end

	context 'invalid request' do

		describe 'GET index' do
			it 'should return 401' do
				get :index
				expect(response.status).to eq(401)
			end
		end
	end



end
