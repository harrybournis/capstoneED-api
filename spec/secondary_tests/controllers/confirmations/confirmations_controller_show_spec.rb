require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'ConfirmationsController /show', type: :controller do

  before(:each) do
    @controller = V1::ConfirmationsController.new
    request.env['devise.mapping'] = Devise.mappings[:v1_user]
    @user = FactoryBot.create(:lecturer)
    expect(@user.confirmed?).to be_falsy
  end

  context 'valid request' do

    it "confirms user's account", { docs?: true } do
      expect(@user.confirmed?).to eq(false)
      get :show, params: { confirmation_token: @user.confirmation_token }
      expect(@controller.params).to include('confirmation_token')
      @user.reload
      expect(assigns(:user).errors.empty?).to be_truthy
      expect(@user.confirmed?).to eq(true)
      expect(User.find_by_confirmation_token(@controller.params[:confirmation_token])).to eq(@user)
    end

    it 'redirects to after_confirmation_path_for' do
      get :show, params: { confirmation_token: @user.confirmation_token }
      expect(response.status).to eq(302)
      expect(response).to redirect_to('/user_confirmation_success.html')
    end
  end

  context 'invalid request' do
    it 'user remains unconfirmed if wrong confirmation_token', { docs?: true } do
      expect(@user.confirmed?).to eq(false)
      get :show, params: { confirmation_token: "#{@user.confirmation_token}dljkafdjklfdakjldfsaldfas" }
      expect(@controller.params).to include('confirmation_token')
      @user.reload
      expect(@user.confirmed?).to eq(false)
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/user_confirmation_failure.html")
    end

    it 'redirects to confirmation_failed if no confirmation token in params' do
      get :show
      expect(@controller.params).to_not include('confirmation_token')
      expect(@user.confirmed?).to eq(false)
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/user_confirmation_failure.html")
    end

    it 'redirects to confirmation_failed if user already confirmed' do
      @user.confirm
      expect(@user.confirmed?).to eq(true)
      get :show, params: { confirmation_token: @user.confirmation_token }
      expect(@controller.params).to include('confirmation_token')
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/user_confirmation_failure.html")
    end
  end
end
