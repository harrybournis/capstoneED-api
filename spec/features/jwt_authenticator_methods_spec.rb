module JWTAuth
	require 'rails_helper'
	require 'helpers/mock_request.rb'

	RSpec.describe "JWTAuthenticator methods" do


		context 'valid request' do

			let(:request) { MockRequest.new(valid = true) }
			let(:csrf) { "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs=" }

			describe 'authenticate' do
				it "should return the user's jti (hardcoded)" do
					expect(JWTAuthenticator.authenticate(request)).to eq("i7sqeESEDJHUSBZd4HJN42o1")
				end
			end

			describe 'refresh' do

				context 'token is not revoked' do
					it 'no revoked tokens exist for the user in the database'
					it 'response headers should contain two new cookies with tokens'
					it 'response headers should contain a new csrf token'
				end

				context 'token is revoked' do
					it 'has revoked token entry for the user in database'
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

			describe 'authenticate' do

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
