module JWTAuth
	require 'rails_helper'
	require 'helpers/mock_request.rb'

	RSpec.describe "JWTAuthenticator request_validating/encoding/decoding" do

		## Valid Request ##
		context 'valid request' do

			let(:request) { MockRequest.new(valid = true) }
			let(:csrf) { "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs=" }

			it 'access request should contain X-XSRF-TOKEN and access-token' do
				expect(request.headers).to include('X-XSRF-TOKEN')
				expect(request.cookies).to include('access-token')
				expect(JWTAuthenticator.valid_access_request(request)).to be_truthy
			end

			it 'refresh request should contain X-XSRF-TOKEN, access-token and refresh-token' do
				expect(request.headers).to include('X-XSRF-TOKEN')
				expect(request.cookies).to include('access-token')
				expect(request.cookies).to include('refresh-token')
				expect(JWTAuthenticator.valid_refresh_request(request)).to be_truthy
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

		## Invalid Request ##
		context 'invalid request' do
			let(:request) { MockRequest.new(valid = false) }

			it 'with different secret should decode to invalid' do
				request.cookies["access-token"] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.zmFcnqovR_295pC6QfvJ2RMAncTEBFJoxS4GydfKo18"
				exception = false
				begin
					decoded_token = JWTAuthenticator.decode_token(request.cookies["access-token"])
				rescue => e
					exception = e.message
				end

				expect(exception).to be_truthy
				expect(decoded_token).to be_falsy
			end
		end

		it 'should not accept time older than now' do
			user = FactoryGirl.build(:user)
			time = Time.now - 10.minutes
			token = JWTAuthenticator.encode_token(user, time)

			expect(token).to be_falsy
		end

	end
end
