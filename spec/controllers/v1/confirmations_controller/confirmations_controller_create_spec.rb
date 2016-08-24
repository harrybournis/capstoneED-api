require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'ConfirmationsController /create', type: :controller do

  before(:each) do
    @controller = V1::ConfirmationsController.new
    request.env['devise.mapping'] = Devise.mappings[:v1_user]
    @user = FactoryGirl.create(:user)
    expect(@user.confirmed?).to be_falsy
  end

  context 'valid request' do

    it 'sends an email with confirmation instructions' do
      expect(@user.confirmed?).to be_falsy
      post :create, params: { email: @user.email }
      expect(response.status).to eq(204)
      expect(ActionMailer::Base.deliveries.last.to.first).to eq(@user.email)
    end

  end

  context 'invalid request' do
    it 'responds with 422 unprocessable_entity if user already confirmed' do
      @user.confirm
      expect(@user.confirmed?).to be_truthy
      post :create, params: { email: @user.email }
      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)['errors']['email'].first).to eq("was already confirmed, please try signing in")
    end

    it 'responds with 422 unprocessable_entity if email is not included' do
      expect(@user.confirmed?).to be_falsy
      old_conf_token = @user.confirmation_token
      post :create
      expect(response.status).to eq(422)
      @user.reload
      expect(@user.confirmation_token).to eq(old_conf_token)
      expect(JSON.parse(response.body)['errors']['email'].first).to eq("can't be blank")
    end

    it 'responds with 422 unprocessable_entity if email does not exist in database' do
      expect(@user.confirmed?).to be_falsy
      old_conf_token = @user.confirmation_token
      post :create, params: { email: 'wrong_email@doesnt_exist.com' }
      expect(response.status).to eq(422)
      @user.reload
      expect(@user.confirmation_token).to eq(old_conf_token)
      expect(JSON.parse(response.body)['errors']['email'].first).to eq("not found")
    end
  end
end
