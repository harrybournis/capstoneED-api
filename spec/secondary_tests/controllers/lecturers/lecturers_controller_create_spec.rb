require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::LecturersController POST /create', type: :controller do

	before(:all) do
		@controller = V1::UsersController.new
	end

	context 'valid request' do

		before(:each) do
			@lecturer = FactoryBot.build(:lecturer)
		end

		describe 'POST create' do
			it 'creates a new user and save them in the database', { docs?: true } do
				expect {
					post :create, params: FactoryBot.attributes_for(:lecturer_with_password)
				}. to change { Lecturer.count }

				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(status).to eq(201)
				expect(assigns[:user].valid?).to be_truthy
				expect(assigns[:user].persisted?).to be_truthy
			end

			it 'encrypts the users password before saving' do
				post :create, params: FactoryBot.attributes_for(:lecturer_with_password)
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(status).to eq(201)
				expect(Lecturer.find(assigns[:user].id).encrypted_password).to_not eq(request.params['password'])
				expect(assigns[:user].valid_password?(request.params['password'])).to be_truthy
			end

			it 'returns 201 created' do
				post :create, params: FactoryBot.attributes_for(:lecturer_with_password)
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(status).to eq(201)
			end

			it 'has email as a provider' do
				post :create, params: FactoryBot.attributes_for(:lecturer_with_password)
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation', 'first_name', 'last_name')
				expect(status).to eq(201)
				expect(assigns[:user].provider).to eq('email')
			end

			it 'sends confirmation email' do
				post :create, params: FactoryBot.attributes_for(:lecturer_with_password)
				expect(status).to eq(201)
				expect(ActionMailer::Base.deliveries.last.to.first).to eq(request.params['email'])
			end

      it 'does not create a student profile if new user is a lecturer' do
				expect {
				  post :create, params: FactoryBot.attributes_for(:lecturer_with_password)
				}. to_not change { StudentProfile.count }
      end
		end

	end

	context 'invalid request' do

		describe 'POST create', { docs?: true } do
			it 'returns 400 bad request if the request is not formatted right' do
				post :create, params: { 'user' => { 'email' => 'email@email.com', 'password' => '12345678', 'password_confirmation' => '12345678', type: 'Lecturer' } }
				expect(status).to eq(422)
				expect(errors['type'][0]).to include('must be either Student or Lecturer')
			end

			it 'returns 422 unprocessable_entity if email error', { docs?: true } do
				post :create, params: { 'email' => 'emailemail.com', 'password' => '12345678', 'password_confirmation' => '12345678', 'first_name' => 'Rixardos', 'last_name' => 'Arlekinos', type: 'Lecturer' }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(status).to eq(422)
				expect(errors['email'].first).to eq('is invalid')
			end

			it 'returns 422 unprocessable_entity if passwords dont match', { docs?: true } do
				post :create, params: { 'email' => 'email@email.com', 'password' => 'asdfasdf', 'password_confirmation' => '12345678', 'first_name' => 'Rixardos', 'last_name' => 'Arlekinos', type: 'Lecturer' }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(status).to eq(422)
				expect(errors['password_confirmation'].first).to eq("doesn't match Password")
			end

			it 'returns 422 unprocessable_entity if password too short', { docs?: true } do
				post :create, params: { 'email' => 'emailmail.com', 'password' => '1234', 'password_confirmation' => '1234',  'last_name' => 'Arlekinos', type: 'Lecturer' }
				expect(controller.params.keys).to include('email', 'password', 'password_confirmation')
				expect(status).to eq(422)
				expect(errors['password'].first).to eq("is too short (minimum is 8 characters)")
			end
		end
	end
end
