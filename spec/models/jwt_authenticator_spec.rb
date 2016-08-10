require 'rails_helper'
require 'helpers/mock_request.rb'

RSpec.describe JWTAuthenticator, type: :request do

	context 'valid request' do

		let(:request) { MockRequest.new(valid = true) }
		let(:csrf) { "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs=" }

		describe 'authenticate' do

		end

		it 'access request should contain X-XSRF-TOKEN and access-token' do
			expect(request.headers).to include('X-XSRF-TOKEN')
			expect(request.cookies).to include('access-token')
			expect(JWTAuthenticator.validate_access_request(request)).to be_truthy
		end

		it 'refresh request should contain X-XSRF-TOKEN, access-token and refresh-token' do
			expect(request.headers).to include('X-XSRF-TOKEN')
			expect(request.cookies).to include('access-token')
			expect(request.cookies).to include('refresh-token')
			expect(JWTAuthenticator.validate_refresh_request(request)).to be_truthy
		end

		it 'encoding with csrf should return a valid access-token' do
			user = FactoryGirl.create(:user)
			token = JWTAuthenticator.encode_token(user, Time.now, csrf)

			exception = false
			begin
				decoded_token = JWTAuthenticator.decode_token(token)
			rescue => e
				exception = e.message
			end

			expect(decoded_token.first["csrf_token"]).to eq(csrf)
		end

		it 'encoding without csrf should return a valid refresh-token' do
			user = FactoryGirl.create(:user)
			token = JWTAuthenticator.encode_token(user, Time.now)

			exception = false
			begin
				decoded_token = JWTAuthenticator.decode_token(token)
			rescue => e
				exception = e.message
			end

			expect(decoded_token).to be_truthy
			expect(decoded_token.first).to_not include("csrf_token")
		end

		it 'decoding should be valid' do
			exception = false
			begin
				decoded_token = JWTAuthenticator.decode_token(request.cookies["access-token"])
			rescue => e
				exception = e.message
			end

			expect(exception).to be_falsy
			expect(decoded_token).to be_truthy
		end
	end

	context 'invalid request' do
		let(:request) { MockRequest.new(valid = false) }
	end

end
