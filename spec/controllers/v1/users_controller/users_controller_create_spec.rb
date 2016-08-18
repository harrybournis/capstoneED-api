require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::UsersController POST /create', type: :controller do

	before(:all) do
		@controller = V1::UsersController.new
	end

	context 'valid request' do

		describe 'POST create' do
			it 'creates a new user and save them in the database' do
				user = FactoryGirl.build(:user)
				expect { post :create, params: { 'email' => 'email@email.com', 'password' => '12345678',
					'password_confirmation' => '12345678', 'first_name' => user.first_name,
					'last_name' => user.last_name }
				}. to change { User.count }

				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(response.status).to eq(201)
				expect(assigns[:user].valid?).to be_truthy
				expect(assigns[:user].persisted?).to be_truthy
			end

			it 'encrypts the users password before saving' do
				user = FactoryGirl.build(:user)
				post :create, params: { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => user.first_name, 'last_name' => user.last_name }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(response.status).to eq(201)
				expect(User.find(assigns[:user].id).encrypted_password).to_not eq(request.params['password'])
				expect(assigns[:user].valid_password?(request.params['password'])).to be_truthy
			end

			it 'returns 201 created' do
				user = FactoryGirl.build(:user)
				post :create, params: { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => user.first_name, 'last_name' => user.last_name }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(response.status).to eq(201)
			end

			it 'has email as a provider' do
				user = FactoryGirl.build(:user)
				post :create, params: { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => user.first_name, 'last_name' => user.last_name }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(response.status).to eq(201)
				expect(assigns[:user].provider).to eq('email')
			end
		end

	end

	context 'invalid request' do

		describe 'POST create' do
			it 'returns 400 bad request if the request is not formatted right' do
				post :create, params: { 'user' => { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678' } }
				expect(response.status).to eq(400)
			end

			it 'returns 422 unprocessable_entity if email error' do
				post :create, params: { 'email' => 'emailemail.com', 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => 'Rixardos', 'last_name' => 'Arlekinos' }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(response.status).to eq(422)
				errors_body = JSON.parse(response.body)
				expect(errors_body['email'].first).to eq('is invalid')
			end

			it 'returns 422 unprocessable_entity if passwords dont match' do
				post :create, params: { 'email' => 'email@email.com', 'password' => 'asdfasdf', 'password_confirmation' => '12345678', 'first_name' => 'Rixardos', 'last_name' => 'Arlekinos' }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(response.status).to eq(422)
				errors_body = JSON.parse(response.body)
				expect(errors_body['password_confirmation'].first).to eq("doesn't match Password")
			end

			it 'returns 422 unprocessable_entity if password too short' do
				post :create, params: { 'email' => 'email@email.com', 'password' => '1234', 'password_confirmation' => '1234', 'first_name' => 'Rixardos', 'last_name' => 'Arlekinos' }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(response.status).to eq(422)
				errors_body = JSON.parse(response.body)
				expect(errors_body['password'].first).to eq("is too short (minimum is 6 characters)")
			end

		end
	end



end
