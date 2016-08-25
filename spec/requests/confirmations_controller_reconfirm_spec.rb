require 'rails_helper'

RSpec.describe "Confirmation Controller - Reconfirmation" do

	it 'user can sign in while with the old password while waiting for reconfirmation' do
		user = FactoryGirl.build(:user_with_password).process_new_record
		user.save
		user.confirm

		post '/v1/sign_in', params: { email: user.email, password: '12345678' }

		expect(response.status).to eq(200)

		old_email = user.email
		csrf = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']

		patch "/v1/users/#{user.id}", params: { id: user.id, email: 'different@email.com' }, headers: { 'X-XSRF-TOKEN' => csrf }

		expect(response.status).to eq(200)

		user.reload
		expect(user.email).to eq(old_email)
		expect(user.unconfirmed_email).to eq('different@email.com')

		delete '/v1/sign_out', headers: { 'X-XSRF-TOKEN' => csrf }

		expect(response.status).to eq(204)

		post '/v1/sign_in', params: { email: user.email, password: '12345678' }
		expect(response.status).to eq(200)
	end

	it 'user cannot sign in until they have confirmed their register email' do
		user = FactoryGirl.build(:user_with_password).process_new_record
		user.save

		post '/v1/sign_in', params: { email: user.email, password: '12345678' }

		expect(response.status).to eq(401)
		expect(JSON.parse(response.body)['errors']['email'].first).to eq('is unconfirmed')
	end

end
