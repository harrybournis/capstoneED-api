require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'PasswordsController /create', type: :controller do

  before(:each) do
    @controller = V1::PasswordsController.new
    request.env['devise.mapping'] = Devise.mappings[:v1_user]
    @user = FactoryGirl.build(:user_with_password).process_new_record
    @user.save
  end

  context 'valid request' do

    it 'sends an email with password reset instructions' do
      expect(@user.reset_password_token).to be_falsy
      post :create, params: { email: @user.email }
      expect(response.status).to eq(200)
      expect(ActionMailer::Base.deliveries.last.to.first).to eq(@user.email)
      @user.reload
      expect(@user.reset_password_token).to be_truthy
    end

  end

  context 'invalid request' do

    it 'responds with 403 unprocessable_entity if user did not sign up by email' do
      @user  = FactoryGirl.create(:user)
      expect(@user.provider).to_not eq('email')
      expect(@user.reset_password_token).to be_falsy
      post :create, params: { email: @user.email }
      expect(response.status).to eq(403)
    end

    it 'responds with 422 unprocessable_entity if email is not included' do
      expect(@user.reset_password_token).to be_falsy
      post :create
      expect(response.status).to eq(422)
      @user.reload
      expect(@user.reset_password_token).to be_falsy
    end

    it 'responds with 422 unprocessable_entity if email does not exist in database' do
      expect(@user.reset_password_token).to be_falsy
      post :create, params: { email: 'wrong_email@doesnt_exist.com' }
      expect(response.status).to eq(422)
      @user.reload
      expect(@user.reset_password_token).to be_falsy
    end
  end
end
