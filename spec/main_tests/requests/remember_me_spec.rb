require 'rails_helper'

RSpec.describe "Remember me", type: :request do

	before(:each) { host! 'api.example.com' }

	it 'remember me is not null' do
		lecturer = FactoryGirl.create(:lecturer_with_password).process_new_record
		lecturer.save
		lecturer.confirm

		post '/v1/sign_in', params: { email: lecturer.email, password: '12345678' }
		expect(status).to eq(200)
		refresh_token = JWTAuth::JWTAuthenticator.decode_token(response.cookies['refresh-token'])

		expect(refresh_token.first['remember_me']).to eq(false)

		post '/v1/refresh'
		expect(status).to eq(204)
		refresh_token = JWTAuth::JWTAuthenticator.decode_token(response.cookies['refresh-token'])

		expect(refresh_token.first['remember_me']).to eq(false)
	end
end
