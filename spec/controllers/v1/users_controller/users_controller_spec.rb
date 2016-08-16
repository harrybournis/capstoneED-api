require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::UsersController POST /create', type: :controller do

	before(:all) do
		@controller = V1::UsersController.new
	end

	context 'valid request' do

		describe 'POST create' do
			it 'has permitted params'
			it 'creates a new user and save them in the database'
			it 'encrypts the users password before saving'
			it 'returns 201 created' do
				user = FactoryGirl.build(:user)
				get :create, params: { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => user.first_name, 'last_name' => user.last_name }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(response.status).to eq(201)
			end
		end

	end

	context 'invalid request' do

		describe 'POST create' do
			it 'returns 400 bad request if the request is not formatted right' do
				get :create, params: { 'user' => { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678' } }
				expect(response.status).to eq(400)
			end
			it 'returns 422 unprocessable_entity if email error' do
				get :create, params: { 'email' => 'emailemail.com', 'password' => '12345678', 'password_confirmation' => '12345678' }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(response.status).to eq(422)
			end
			it 'returns 422 unprocessable_entity if passwords dont match'
			it 'returns 422 unprocessable_entity if password too short'
		end
	end



end
