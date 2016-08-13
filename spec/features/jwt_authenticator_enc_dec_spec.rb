require 'rails_helper'

RSpec.describe "JWTAuthenticator request_validating/encoding/decoding" do

	context 'valid request' do

		it 'access request should contain X-XSRF-TOKEN and access-token' do
			request = MockRequest.new(valid = true)
			csrf = "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs="
			expect(request.headers).to include('X-XSRF-TOKEN')
			expect(request.cookies).to include('access-token')
			expect(JWTAuth::JWTAuthenticator.valid_access_request(request)).to be_truthy
		end

		it 'refresh request should contain refresh-token' do
			request = MockRequest.new(valid = true)
			expect(request.cookies).to include('refresh-token')
			expect(JWTAuthenticator.valid_refresh_request(request)).to be_truthy
		end

		it 'encoding with csrf should return a valid access-token' do
			csrf = "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs="
			user = FactoryGirl.create(:user)
			token = JWTAuthenticator.encode_token(user, Time.now, csrf)

			exception = false
			begin
				decoded_token = JWTAuthenticator.decode_token(token)
			rescue => e
				exception = e.message
			end

			expect(decoded_token.first["csrf_token"]).to eq(csrf)
			expect(exception).to be_falsy
		end

		it 'encoding without csrf should return a valid refresh-token' do
			user = FactoryGirl.create(:user)
			device = SecureRandom.base64(32)
			token = JWTAuthenticator.encode_token(user, Time.now, nil, device)

			exception = false
			begin
				decoded_token = JWTAuthenticator.decode_token(token)
			rescue => e
				exception = e.message
			end

			expect(exception).to be_falsy
			expect(decoded_token).to be_truthy
			expect(decoded_token.first).to_not include("csrf_token")
			expect(decoded_token.first['device']).to be_truthy
		end

		it 'decoding access-access should be valid' do
			request = MockRequest.new(valid = true)
			exception = false
			begin
				decoded_token = JWTAuthenticator.decode_token(request.cookies["access-token"])
			rescue => e
				exception = e.message
			end

			expect(exception).to be_falsy
			expect(decoded_token).to be_truthy
		end

		it 'decoding refresh-token should be valid' do
			request = MockRequest.new(valid = true)
			exception = false
			begin
				decoded_token = JWTAuthenticator.decode_token(request.cookies["refresh-token"])
			rescue => e
				exception = e.message
			end

			expect(exception).to be_falsy
			expect(decoded_token).to be_truthy
			expect(decoded_token.first['device']).to be_truthy
		end
	end

	## Invalid Request ##
	context 'invalid request' do

		it 'with different secret should decode to invalid' do
			request = MockRequest.new(valid = false)
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

		describe 'valid_access_request and valid_refresh_request' do
			it 'should return a ValidatedRequest object since headers are correct' do
				request = MockRequest.new(valid = false)
				expect(JWTAuthenticator.valid_access_request(request)).to_not be_falsy
				expect(JWTAuthenticator.valid_refresh_request(request)).to_not be_falsy
			end
		end
	end

	context 'request without correct headers' do

		describe 'valid_access_request and valid_refresh_request' do
			it 'should return nil if X-XSRF-TOKEN is missing' do
				request = MockRequest.new(valid = true)
				request.headers.delete("X-XSRF-TOKEN")
				expect(JWTAuthenticator.valid_access_request(request)).to be_falsy
			end

			it 'should return nil if access-token is missing' do
				request = MockRequest.new(valid = true)
				request.cookies.delete("access-token")
				expect(JWTAuthenticator.valid_access_request(request)).to be_falsy
			end

			it 'should return nil if the refresh-token is missing' do
				request = MockRequest.new(valid = true)
				request.cookies.delete("refresh-token")
				expect(JWTAuthenticator.valid_refresh_request(request)).to be_falsy
			end
		end
	end

end

