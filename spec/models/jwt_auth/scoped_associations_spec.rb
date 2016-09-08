require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe JWTAuth::CurrentUser, type: :model do
	JWTAuthenticator = JWTAuth::JWTAuthenticator
	CurrentUser = JWTAuth::CurrentUser

	describe 'Scoped Associations' do

		before(:each) do
			@user = FactoryGirl.create(:lecturer)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = CurrentUser.new(@token_id, 'Lecturer', @device)
		end

		it 'correct scoped assosciation is loaded' do
			expect(@current_user.scoped_association).to eq('Lecturer')

			@user = FactoryGirl.create(:student)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = CurrentUser.new(@token_id, 'Student', @device)

			expect(@current_user.scoped_association).to eq('Student')
		end
	end
end
