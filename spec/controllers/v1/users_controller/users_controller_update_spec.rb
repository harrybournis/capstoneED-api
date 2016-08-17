require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::UsersController PUT /update', type: :controller do

	before(:each) do
		@controller = V1::UsersController.new
		@new_en = FactoryGirl.build(:user_with_password).process_new_record
		@new_en.save
		mock_request = MockRequest.new(valid = true, @new_en)
		request.cookies['access-token'] = mock_request.cookies['access-token']
		request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
		expect(request.headers['X-XSRF-TOKEN']).to be_truthy
	end

	context 'valid request' do

		describe 'PUT update' do
			it "replaces user's first_name with the first_name in the params" do
				old_name = @new_en.first_name
				expect {
					put :update, params: { id: @new_en.id, first_name: 'different' }
				}.to change { User.find(@new_en.id).first_name }.from(old_name).to('different')

				expect(User.find(@new_en.id).first_name).to eq('different')
			end

			it 'does not change the number of users in the database' do
				expect {
					put :update, params: { id: @new_en.id, first_name: 'different' }
				}.to_not change{ User.count }
			end

			it 'returns 200 ok with the updated user' do
				put :update, params: { id: @new_en.id, first_name: 'different' }
				expect(response.status).to eq(200)
				res_body = JSON.parse(response.body)
				expect(res_body).to include('user')
				expect(res_body['user']['id']).to eq(@new_en.id)
				@new_en.reload
				expect(res_body['user']['first_name']).to eq('different')
			end

			it 'requires the old password to update the password' do
				put :update, params: { id: @new_en.id, password: 'qwertyuiop',
					password_confirmation: 'qwertyuiop', current_password: '12345678'  }
				@new_en.reload
				expect(@new_en.valid_password?('qwertyuiop')).to be_truthy
				expect(@new_en.valid_password?('12345678')).to be_falsy
			end
		end
	end

	context 'invalid request' do

		describe 'PUT update' do
			it 'ignores updates to the provider field' do
				put :update, params: { id: @new_en.id, provider: 'facebook', last_name: 'new_last_name' }
				expect(response.status).to eq(200)
				@new_en.reload
				expect(@new_en.provider).to eq('email')
				expect(@new_en.last_name).to eq('new_last_name')
			end

			it 'returns 401 if authentication problem' do
				@controller = V1::UsersController.new
				@new_en = FactoryGirl.build(:user_with_password).process_new_record
				@new_en.save
				mock_request = MockRequest.new(valid = false, @new_en)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				expect { put :update, params: { id: @new_en.id, first_name: 'first' } }.to_not make_database_queries
				expect(response.status).to eq(401)
				@new_en.reload
				expect(@new_en.first_name).to_not eq('first')

			end

			it 'returns 403 forbidden if the user to be updated is not the current user' do
				different_user = FactoryGirl.create(:user)
				old_name = different_user.first_name
				put :update, params: { id: different_user.id, first_name: 'change_their_name' }

				expect(response.status).to eq(403)
				different_user.reload
				expect(different_user.first_name).to_not eq('change_their_name')
				expect(different_user.first_name).to eq(old_name)
			end

			it 'returns 422 unprocessable_entity if email format wrong' do
				old_email = @new_en.email
				put :update, params: { id: @new_en.id, email: 'new_emailnew_email.com' }

				@new_en.reload
				expect(response.status).to eq(422)
				expect(@new_en.email).to_not eq('new_emailnew_email.com')
				expect(@new_en.email).to eq(old_email)
			end

			it 'returns 422 unprocessable_entity if password confirmation does not match' do
				put :update, params: { id: @new_en.id, password: 'qwertyuiop',
					password_confirmation: 'different_password', current_password: '12345678' }

				@new_en.reload
				expect(response.status).to eq(422)
				expect(@new_en.valid_password?('qwertyuiop')).to be_falsy
				expect(@new_en.valid_password?('12345678')).to be_truthy
				res_body = JSON.parse(response.body)
				expect(res_body['password_confirmation']).to include("doesn't match Password")
			end

			it 'returns 422 unprocessable_entity if old password is invalid' do
				put :update, params: { id: @new_en.id, password: 'qwertyuiop',
					password_confirmation: 'qwertyuiop', current_password: 'wrong_password'  }
				@new_en.reload
				expect(response.status).to eq(422)
				expect(@new_en.valid_password?('qwertyuiop')).to be_falsy
				expect(@new_en.valid_password?('wrong_password')).to be_falsy
				res_body = JSON.parse(response.body)
				expect(res_body['current_password']).to_not be_empty
			end
		end
	end
end
