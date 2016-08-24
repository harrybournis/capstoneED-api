require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'ConfirmationsController /show', type: :controller do

  before(:each) do
    @controller = V1::PasswordsController.new
    request.env['devise.mapping'] = Devise.mappings[:v1_user]
    @user = FactoryGirl.build(:user_with_password).process_new_record
    @user.save
    expect(@user.reset_password_token).to be_falsy
    @user = User.send_reset_password_instructions({email: @user.email})
    expect(@user.reset_password_token).to be_truthy
    expect(ActionMailer::Base.deliveries.last.to.first).to eq(@user.email)
    message = ActionMailer::Base.deliveries.last.body.to_s
    rpt_index = message.index("reset_password_token")+"reset_password_token".length+1
    @token = message[rpt_index...message.index("\"", rpt_index)]
  end

  context 'valid request' do

    it "resets user's password" do
    	old_password = @user.encrypted_password
    	expect(@user.valid_password?('abcdefgh')).to be_falsy
      post :update, params: { reset_password_token: @token, password: 'password1', password_confirmation: 'password1' }
      expect(assigns(:user).errors).to be_empty
      expect(response.status).to eq(204)
      @user.reload
      expect(@user.encrypted_password).to_not eq(old_password)
      expect(@user.reset_password_token?).to be_falsy
      expect(@user.valid_password?('password1')).to be_truthy
    end

  end

  context 'invalid request' do
    it 'password remains the same if wrong password_reset_token' do
      post :update, params: { reset_password_token: 'randomsdfalkjfdljfsadljfdsaklfdsalk', password: 'abcdefgh', password_confirmation: 'abcdefgh' }
      @user.reload
      expect(response.status).to eq(422)
      expect(@user.valid_password?('abcdefgh')).to be_falsy
    end

    it '400 bad request if no password_reset_token in params' do
      post :update, params: { password: 'abcdefgh', password_confirmation: 'abcdefgh' }
      @user.reload
      expect(response.status).to eq(400)
      expect(@user.valid_password?('abcdefgh')).to be_falsy
      expect(JSON.parse(response.body)['errors']['reset_password_token'].first).to eq("can't be blank")
    end
  end
end
