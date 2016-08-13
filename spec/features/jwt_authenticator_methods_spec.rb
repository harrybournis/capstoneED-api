require 'rails_helper'
require 'helpers/mock_request.rb'
require 'helpers/mock_response.rb'

RSpec.describe "JWTAuthenticator method" do

	describe 'sign-in' do

		before(:each) do
			@response = MockResponse.new
			@user = FactoryGirl.create(:user)
			@cookies = {}
		end

		it 'returns a response with an access token, a refresh token, and a csrf token in the headers' do
			expect(JWTAuthenticator.sign_in(@user, @response, @cookies)).to be_truthy
			expect(@response.headers).to include('csrf_token')
			expect(@cookies["access-token"]).to be_truthy
			expect(@cookies["refresh-token"]).to be_truthy
		end

		it 'creates a active_token database entry with the exp of the new refresh token' do
			original_active_tokens = @user.active_tokens.count
			expect(JWTAuthenticator.sign_in(@user, @response, @cookies)).to be_truthy
			expect(ActiveToken.last.user).to eq(@user)
			expect(@user.active_tokens.count).to eq(original_active_tokens + 1)
		end

	end

	describe 'create_new_tokens' do

		it 'returns a response with an access token, a refresh token, and a csrf token in the headers' do
			response = MockResponse.new
			user = FactoryGirl.create(:user)
			cookies = {}
			new_device = SecureRandom.base64(32)
			time_now   = Time.now
			expect(JWTAuthenticator.create_new_tokens(user, response, cookies, new_device, time_now)).to be_truthy
			expect(response.headers).to include('csrf_token')
			expect(cookies["access-token"]).to be_truthy
			expect(cookies["refresh-token"]).to be_truthy
		end
	end

	context 'valid request' do

		describe 'authenticated' do
			it "should return the user's uid (hardcoded)" do
				user = FactoryGirl.create(:user)
				request = MockRequest.new(valid = true, user)
				expect(JWTAuthenticator.authenticate(request)).to eq(user.uid)#"i7sqeESEDJHUSBZd4HJN42o1")
			end
		end

		describe 'refresh' do

			context 'refresh token is not revoked' do

				before(:each) do
					user = FactoryGirl.create(:user)
					device = SecureRandom.base64(32)
					time_before = DateTime.now - 1.hour
					valid_token = FactoryGirl.create(:active_token, exp: time_before, device: device, user: user)
					expect(valid_token.device).to eq(device)
					expect(ActiveToken.last).to eq(valid_token)

					@request = MockRequest.new(true, user, device)
					@response = MockResponse.new
					@cookies = {}
				end

				it "active token's expiration date is smaller than the refresh tokens'" do
					validated_request = JWTAuthenticator.valid_refresh_request(@request)
					expect(validated_request).to be_truthy
					decoded_token = JWTAuthenticator.decode_token(validated_request.refresh_token)
					valid_token = ActiveToken.find_by_device(decoded_token.first['device'])
					expect(decoded_token.first['exp'] > valid_token.exp.to_i).to be_truthy

					expect(JWTAuthenticator.refresh(@request, @response, @cookies)).to be_truthy
				end

				it 'response should contain two new cookies with tokens' do
					old_access_token = @request.cookies['access-token'] if @request.cookies['access-token']
					old_refresh_token = @request.cookies['refresh-token']
					expect(JWTAuthenticator.refresh(@request, @response, @cookies)).to be_truthy
					expect(@cookies.size).to eq(2)
					expect(@cookies['access-token']).to be_truthy
					expect(@cookies['access-token']).to_not eq(old_access_token)
					expect(@cookies['refresh-token']).to be_truthy
					expect(@cookies['refresh-token']).to_not eq(old_refresh_token)
				end

				it 'response headers should contain a new csrf token' do
					old_csrf = @request.headers['csrf_token']
					expect(JWTAuthenticator.refresh(@request, @response, @cookies)).to be_truthy
					expect(@response.headers['csrf_token']).to be_truthy
					expect(@response.headers['csrf_token']).to_not eq(old_csrf)
				end

				it 'should update the active_token in the database with the new expiration date' do
					validated_request = JWTAuthenticator.valid_refresh_request(@request)
					expect(validated_request).to be_truthy
					decoded_token = JWTAuthenticator.decode_token(validated_request.refresh_token)
					valid_token = ActiveToken.find_by_device(decoded_token.first['device'])
					expect(valid_token).to be_truthy

					old_active_token_time = valid_token.exp

					expect(JWTAuthenticator.refresh(@request, @response, @cookies)).to be_truthy
					valid_token = ActiveToken.find_by_device(decoded_token.first['device'])
					expect(old_active_token_time).to be < valid_token.exp
				end
			end

			context 'refresh token is revoked' do

				before(:each) do
					user = FactoryGirl.create(:user)
					device = SecureRandom.base64(32)
					time_before = DateTime.now + JWTAuthenticator.refresh_exp
					@valid_token = FactoryGirl.create(:active_token, exp: time_before, device: device, user: user)
					expect(@valid_token.device).to eq(device)
					expect(ActiveToken.last).to eq(@valid_token)

					@request = MockRequest.new(true, user, device)
					@response = MockResponse.new
					@cookies = {}
				end

				it "revoked token's expiration date is bigger than the refresh tokens' " do
					validated_request = JWTAuthenticator.valid_refresh_request(@request)
					expect(validated_request).to be_truthy
					decoded_token = JWTAuthenticator.decode_token(validated_request.refresh_token)
					valid_token = ActiveToken.find_by_device(decoded_token.first['device'])
					expect(decoded_token.first['exp'] > valid_token.exp.to_i).to be_falsy

					expect(JWTAuthenticator.refresh(@request, @response, @cookies)).to be_falsy
				end

				it 'should not update the active_token in the database for this device' do
					expect {
						JWTAuthenticator.refresh(@request, @response, @cookies)
						}.to_not change { ActiveToken.last }
					expect(@valid_token).to eq(ActiveToken.last)
				end

				it 'returns nil' do
					expect(JWTAuthenticator.refresh(@refresh, @response, @cookies)).to be_falsy
				end
			end
		end

	end


	context 'invalid request' do

		describe 'authenticate' do
			it 'should return nil (hardcoded)' do
				request = MockRequest.new(valid = false)
				expect(JWTAuthenticator.authenticate(request)).to be_falsy
			end
		end

		describe 'refresh' do
			it 'should be falsy' do
				request = MockRequest.new(valid = false)
				response = MockResponse.new
				cookies = {}
				expect(JWTAuthenticator.refresh(request, response, cookies)).to be_falsy
			end
		end

	end


	context 'request without correct headers' do

		describe 'authenticate' do

			it 'should return nil if X-XSRF-TOKEN is missing' do
				request = MockRequest.new(valid = true)
				request.headers.delete("X-XSRF-TOKEN")
				expect(JWTAuthenticator.authenticate(request)).to be_falsy
			end

			it 'should return nil if access-token is missing' do
				request = MockRequest.new(valid = true)
				request.cookies.delete("access-token")
				expect(JWTAuthenticator.authenticate(request)).to be_falsy
			end
		end

		describe 'refresh' do

			before(:each) do
				@request = MockRequest.new(valid = true)
				@response = MockResponse.new
				@cookies = {}
			end

			it 'should return nil if X-XSRF-TOKEN is missing' do
				@request.headers.delete("X-XSRF-TOKEN")
				expect(JWTAuthenticator.refresh(@request, @response, @cookies)).to be_falsy
			end

			it 'should return nil if access-token is missing' do
				@request.cookies.delete("access-token")
				expect(JWTAuthenticator.refresh(@request, @response, @cookies)).to be_falsy
			end

			it 'should return nil if the refresh-token is missing' do
				@request.cookies.delete("refresh-token")
				expect(JWTAuthenticator.refresh(@request, @response, @cookies)).to be_falsy
			end
		end

	end

end
