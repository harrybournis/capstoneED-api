require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::UsersController POST /create', type: :controller do

	before(:all) do
		@controller = V1::UsersController.new
	end

	context 'valid request' do

		describe 'POST register' do
			it 'has permitted params'
			it 'creates a new user and save them in the database'
			it 'encrypts the users password before saving'
			it 'returns 201 created'
		end

	end

	context 'invalid request' do

		describe 'POST register' do
			it 'returns 400 bad request if the request is not formatted right' do
				get :create, params: { 'user' => { 'email' => 'email@email.com', 'password' => '12345678', 'password-confirmation' => '12345678' } }
				expect(controller.params.permitted?).to be_falsy
				expect(response.status).to eq(400)
			end
			it 'returns 422 unprocessable_entity if email error'
			it 'returns 422 unprocessable_entity if passwords dont match'
			it 'returns 422 unprocessable_entity if password too short'
		end
	end



end
