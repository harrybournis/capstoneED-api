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

			it 'creates a active_token database entry with the exp of the new refresh token' do
				user = FactoryGirl.create(:user)
				cookies = {}
				original_active_tokens = user.active_tokens.count
				expect(JWTAuthenticator.sign_in(user, response, cookies)).to be_truthy
				expect(ActiveToken.last.user).to eq(user)
				expect(user.active_tokens.count).to eq(original_active_tokens + 1)
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

				context 'refresh token is not revoked' do
					it "active token's expiration date is smaller than the refresh tokens'"
					it 'response should contain two new cookies with tokens'
					it 'response headers should contain a new csrf token'
					it 'should update the active_token in the database with the new expiration date'
				end

				context 'refresh token is revoked' do
					it 'revoked token has the same device id'
					it "revoked token's expiration date is bigger than the refresh tokens' "
					it 'should not update the active_token in the database for this device'
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
				let(:response) { MockResponse.new }
				let(:cookies) { {} }

				it 'should return nil if X-XSRF-TOKEN is missing' do
					request.headers.delete("X-XSRF-TOKEN")
					expect(JWTAuthenticator.refresh(request, response, cookies)).to be_nil
				end

				it 'should return nil if access-token is missing' do
					request.cookies.delete("access-token")
					expect(JWTAuthenticator.refresh(request, response, cookies)).to be_nil
				end

				it 'should return nil if the refresh-token is missing' do
					request.cookies.delete("refresh-token")
					expect(JWTAuthenticator.refresh(request, response, cookies)).to be_nil
				end
			end
		end

	end
end
