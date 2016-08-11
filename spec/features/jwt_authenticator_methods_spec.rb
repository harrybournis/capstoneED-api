module JWTAuth
	require 'rails_helper'
	require 'helpers/mock_request.rb'
	require 'helpers/mock_response.rb'

	RSpec.describe "JWTAuthenticator method" do

		describe 'sign-in' do
			let(:response) { MockResponse.new }

			it 'returns a response with an access token, a refresh token, and a csrf token in the headers' do
				user = FactoryGirl.create(:user)
				cookies = {}
				expect(JWTAuthenticator.sign_in(user, response, cookies)).to be_truthy
				expect(response.headers).to include('csrf_token')
				expect(cookies["access-token"]).to be_truthy
				expect(cookies["refresh-token"]).to be_truthy
			end

		end

		context 'valid request' do

			let(:request) { MockRequest.new(valid = true) }

			describe 'authenticate' do
				it "should return the user's uid (hardcoded)" do
					user = FactoryGirl.create(:user)
					request = MockRequest.new(valid = true, user)
					expect(JWTAuthenticator.authenticate(request)).to eq(user.uid)#"i7sqeESEDJHUSBZd4HJN42o1")
				end
			end

			describe 'refresh' do

				context 'token is not revoked' do
					it 'no revoked tokens exist for the user in the database'
					it 'revoked token is for the current device of the user'
					it "revoked token's expiration date is smaller than the refresh tokens'"
					it 'response headers should contain two new cookies with tokens'
					it 'response headers should contain a new csrf token'
					it 'returns response with two new cookies with tokens'
					it 'returns response with a new csrf token in the headers'
				end

				context 'token is revoked' do
					it 'revoked token has the same device id'
					it "revoked token's expiration date is bigger than the refresh tokens' "
					it 'returns nil'
				end
			end
		end


		context 'invalid request' do
			let(:request) { MockRequest.new(valid = false) }

			describe 'authenticate' do
				it 'should return nil (hardcoded)' do
					expect(JWTAuthenticator.authenticate(request)).to be_nil
				end
			end

			describe 'refresh' do
				it 'should return nil' do
					#JWTAuthenticator.refresh(request, response)
				end
			end
		end


		context 'request without correct headers' do
			let(:request) { MockRequest.new(valid = true) }

			describe 'authenticate' do

				it 'should return nil if X-XSRF-TOKEN is missing' do
					request.headers.delete("X-XSRF-TOKEN")
					expect(JWTAuthenticator.authenticate(request)).to be_nil
				end

				it 'should return nil if access-token is missing' do
					request.cookies.delete("access-token")
					expect(JWTAuthenticator.authenticate(request)).to be_nil
				end
			end

			describe 'refresh' do

				# it 'should return nil if X-XSRF-TOKEN is missing' do
				# 	request.headers.delete("X-XSRF-TOKEN")
				# 	expect(JWTAuthenticator.refresh(request, response)).to be_nil
				# end

				# it 'should return nil if access-token is missing' do
				# 	request.cookies.delete("access-token")
				# 	expect(JWTAuthenticator.refresh(request, response)).to be_nil
				# end

				# it 'should return nil if the refresh-token is missing' do
				# 	request.cookies.delete("refresh-token")
				# 	expect(JWTAuthenticator.refresh(request, response)).to be_nil
				# end
			end
		end

	end
end
