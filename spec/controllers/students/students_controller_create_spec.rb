require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::StudentsController POST /create', type: :controller do

	before(:all) do
		@controller = V1::StudentsController.new
	end

	context 'valid request' do

		before(:each) do
			@student = FactoryGirl.build(:student)
		end

		describe 'POST create' do
			it 'creates a new user and save them in the database' do
				expect { post :create, params: { 'email' => 'email@email.com', 'password' => '12345678',
					'password_confirmation' => '12345678', 'first_name' => @student.first_name,
					'last_name' => @student.last_name }
				}. to change { Student.count }

				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(response.status).to eq(201)
				expect(assigns[:student].valid?).to be_truthy
				expect(assigns[:student].persisted?).to be_truthy
			end

			it 'encrypts the users password before saving' do
				post :create, params: { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => @student.first_name, 'last_name' => @student.last_name }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(response.status).to eq(201)
				expect(Student.find(assigns[:student].id).encrypted_password).to_not eq(request.params['password'])
				expect(assigns[:student].valid_password?(request.params['password'])).to be_truthy
			end

			it 'returns 201 created' do
				post :create, params: { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => @student.first_name, 'last_name' => @student.last_name }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(response.status).to eq(201)
			end

			it 'has email as a provider' do
				post :create, params: { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => @student.first_name, 'last_name' => @student.last_name }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(response.status).to eq(201)
				expect(assigns[:student].provider).to eq('email')
			end

			it 'sends confirmation email' do
				post :create, params: { 'email' => @student.email, 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => @student.first_name, 'last_name' => @student.last_name }
				expect(response.status).to eq(201)
				expect(ActionMailer::Base.deliveries.last.to.first).to eq(@student.email)
			end
		end

	end

	context 'invalid request' do

		describe 'POST create' do
			it 'returns 400 bad request if the request is not formatted right' do
				post :create, params: { 'user' => { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678' } }
				expect(response.status).to eq(422)
				expect(parse_body['errors']['email'].first).to eq("can't be blank")
				expect(parse_body['errors']['password'].first).to eq("can't be blank")
				expect(parse_body['errors']['password_confirmation'].first).to eq("can't be blank")
			end

			it 'returns 422 unprocessable_entity if email error' do
				post :create, params: { 'email' => 'emailemail.com', 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => 'Rixardos', 'last_name' => 'Arlekinos' }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(response.status).to eq(422)
				errors_body = JSON.parse(response.body)
				expect(errors_body['errors']['email'].first).to eq('is invalid')
			end

			it 'returns 422 unprocessable_entity if passwords dont match' do
				post :create, params: { 'email' => 'email@email.com', 'password' => 'asdfasdf', 'password_confirmation' => '12345678', 'first_name' => 'Rixardos', 'last_name' => 'Arlekinos' }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(response.status).to eq(422)
				errors_body = JSON.parse(response.body)
				expect(errors_body['errors']['password_confirmation'].first).to eq("doesn't match Password")
			end

			it 'returns 422 unprocessable_entity if password too short' do
				post :create, params: { 'email' => 'emailmail.com', 'password' => '1234', 'password_confirmation' => '1234',  'last_name' => 'Arlekinos' }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(response.status).to eq(422)
				errors_body = JSON.parse(response.body)
				expect(errors_body['errors']['password'].first).to eq("is too short (minimum is 8 characters)")
			end
		end
	end
end
