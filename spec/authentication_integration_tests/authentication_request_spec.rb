require 'rails_helper'

RSpec.describe "Confirmation Controller - Reconfirmation", type: :request do

	before(:all) do
		@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
		@lecturer.save
		@lecturer.confirm
	end

	before(:each) { host! 'api.example.com' }

	describe 'sign_in' do
		it 'allow user to visit /me after signing in and get themselves' do
			post '/v1/sign_in', params: { email: @lecturer.email, password: '12345678', remember_me: '1' }, as: :json
			expect(status).to eq(200)#signin
			expect(response.cookies['access-token']).to be_truthy
			expect(response.cookies['refresh-token']).to be_truthy
			csrf = response.headers['XSRF-TOKEN']

			get '/v1/me', params: nil, headers: { 'X-XSRF-TOKEN' => csrf }, as: :json
			expect(status).to eq(200) #me
			expect(body['user']['first_name']).to eq(@lecturer.first_name)
		end

		it 'allows the user to refresh and get /me succuessfully' do
			post '/v1/sign_in', params: { email: @lecturer.email, password: '12345678', remember_me: '1' }, as: :json
			expect(status).to eq(200)#signin
			csrf = response.headers['XSRF-TOKEN']

			get '/v1/me', params: nil, headers: { 'X-XSRF-TOKEN' => csrf }, as: :json
			expect(status).to eq(200) #me

			cookies.delete("access-token")

			get '/v1/me', params: nil, headers: { 'X-XSRF-TOKEN' => csrf }, as: :json
			expect(status).to eq(401) #me2

			post '/v1/refresh'
			expect(status).to eq(204)

			csrf = response.headers['XSRF-TOKEN']

			get '/v1/me', params: nil, headers: { 'X-XSRF-TOKEN' => csrf }, as: :json
			expect(status).to eq(200) #me3
			expect(body['user']['first_name']).to eq(@lecturer.first_name)
		end
	end

	describe 'sign_out' do

		it 'signs out the user and deletes cookies' do
			post '/v1/sign_in', params: { email: @lecturer.email, password: '12345678', remember_me: '1' }, as: :json
			expect(status).to eq(200)#signin
			csrf = response.headers['XSRF-TOKEN']

			get '/v1/me', params: nil, headers: { 'X-XSRF-TOKEN' => csrf }, as: :json
			expect(status).to eq(200) #me

			delete '/v1/sign_out', params: nil, headers: { 'X-XSRF-TOKEN' => csrf }, as: :json
			expect(status).to eq(204)
			expect(response.cookies['access-token']).to be_falsy
			expect(response.cookies['refresh-token']).to be_falsy

			cookies.delete('access-token') if response.cookies['access-token'].nil?
			cookies.delete('refresh-token') if response.cookies['refresh-token'].nil?

			get '/v1/me', params: nil, headers: { 'X-XSRF-TOKEN' => csrf }, as: :json
			expect(status).to eq(401) #me2
		end
	end
end
