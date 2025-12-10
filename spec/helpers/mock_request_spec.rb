require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth

RSpec.describe MockRequest, type: :model do

	context 'valid request' do
		it 'should encode two valid tokens' do
			user = FactoryBot.create(:user)
			device = SecureRandom.base64(32)
			request = MockRequest.new(true, user, device)

			expect(JWTAuth::JWTAuthenticator.valid_access_request(request)).to be_truthy
			expect(JWTAuth::JWTAuthenticator.valid_refresh_request(request)).to be_truthy

			access_token = JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])
			refresh_token = JWTAuth::JWTAuthenticator.decode_token(request.cookies['refresh-token'])
			expect(access_token).to be_truthy
			expect(refresh_token).to be_truthy
		end
	end

end
