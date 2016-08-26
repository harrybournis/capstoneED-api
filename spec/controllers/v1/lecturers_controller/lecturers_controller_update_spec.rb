require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::LecturersController PUT /update', type: :controller do

	before(:each) do
		@controller = V1::LecturersController.new
		@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
		@lecturer.save
		mock_request = MockRequest.new(valid = true, @lecturer)
		request.cookies['access-token'] = mock_request.cookies['access-token']
		request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
		expect(request.headers['X-XSRF-TOKEN']).to be_truthy
	end

	context 'valid request' do

		describe 'PUT update' do
			it "replaces user's first_name with the first_name in the params" do
				old_name = @lecturer.first_name
				expect {
					put :update, params: { id: @lecturer.id, first_name: 'different' }
				}.to change { Lecturer.find(@lecturer.id).first_name }.from(old_name).to('different')

				expect(Lecturer.find(@lecturer.id).first_name).to eq('different')
			end

			it 'does not change the number of users in the database' do
				expect {
					put :update, params: { id: @lecturer.id, first_name: 'different' }
				}.to_not change{ Lecturer.count }
			end

			it 'returns 200 ok with the updated user' do
				put :update, params: { id: @lecturer.id, first_name: 'different' }
				expect(response.status).to eq(200)
				res_body = JSON.parse(response.body)
				expect(res_body).to include('lecturer')
				expect(res_body['lecturer']['id']).to eq(@lecturer.id)
				@lecturer.reload
				expect(res_body['lecturer']['first_name']).to eq('different')
			end

			it 'requires the old password to update the password' do
				put :update, params: { id: @lecturer.id, password: 'qwertyuiop',
					password_confirmation: 'qwertyuiop', current_password: '12345678'  }
				@lecturer.reload
				expect(@lecturer.valid_password?('qwertyuiop')).to be_truthy
				expect(@lecturer.valid_password?('12345678')).to be_falsy
			end

			it 'updating email sends a new confirmation email' do
				@lecturer.confirm
				expect(@lecturer.confirmed?).to be_truthy
				old_conf_token = @lecturer.confirmation_token
				put :update, params: { id: @lecturer.id, email: 'new_email@email.com'  }
				@lecturer.reload
				expect(@lecturer.confirmation_token).to_not eq(old_conf_token)
				expect(ActionMailer::Base.deliveries.last.to.first).to eq('new_email@email.com')
				@lecturer.reload
				expect(@lecturer.pending_reconfirmation?).to be_truthy
				expect(@lecturer.email).to_not eq('new_email@email.com')
				expect(@lecturer.unconfirmed_email).to eq('new_email@email.com')
			end
		end
	end

	context 'invalid request' do

		describe 'PUT update' do
			it 'ignores updates to the provider field' do
				put :update, params: { id: @lecturer.id, provider: 'facebook', last_name: 'new_last_name' }
				expect(response.status).to eq(200)
				@lecturer.reload
				expect(@lecturer.provider).to eq('email')
				expect(@lecturer.last_name).to eq('new_last_name')
			end

			it 'returns 401 if authentication problem' do
				@controller = V1::LecturersController.new
				@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
				@lecturer.save
				mock_request = MockRequest.new(valid = false, @lecturer)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				expect { put :update, params: { id: @lecturer.id, first_name: 'first' } }.to_not make_database_queries
				expect(response.status).to eq(401)
				@lecturer.reload
				expect(@lecturer.first_name).to_not eq('first')
			end

			it 'returns 403 forbidden if the user to be updated is not the current user' do
				different_user = FactoryGirl.create(:lecturer)
				old_name = different_user.first_name
				put :update, params: { id: different_user.id, first_name: 'change_their_name' }

				expect(response.status).to eq(403)
				different_user.reload
				expect(different_user.first_name).to_not eq('change_their_name')
				expect(different_user.first_name).to eq(old_name)
				expect(JSON.parse(response.body)['errors']['lecturer'].first).to include('not authorized to access this resourse.')
			end

			it 'returns 422 unprocessable_entity if email format wrong' do
				old_email = @lecturer.email
				put :update, params: { id: @lecturer.id, email: 'new_emailnew_email.com' }

				@lecturer.reload
				expect(response.status).to eq(422)
				expect(@lecturer.email).to_not eq('new_emailnew_email.com')
				expect(@lecturer.email).to eq(old_email)
			end

			it 'returns 422 unprocessable_entity if password confirmation does not match' do
				put :update, params: { id: @lecturer.id, password: 'qwertyuiop',
					password_confirmation: 'different_password', current_password: '12345678' }

				@lecturer.reload
				expect(response.status).to eq(422)
				expect(@lecturer.valid_password?('qwertyuiop')).to be_falsy
				expect(@lecturer.valid_password?('12345678')).to be_truthy
				res_body = JSON.parse(response.body)
				expect(res_body['errors']['password_confirmation']).to include("doesn't match Password")
			end

			it 'returns 422 unprocessable_entity if old password is invalid' do
				put :update, params: { id: @lecturer.id, password: 'qwertyuiop',
					password_confirmation: 'qwertyuiop', current_password: 'wrong_password'  }
				@lecturer.reload
				expect(response.status).to eq(422)
				expect(@lecturer.valid_password?('qwertyuiop')).to be_falsy
				expect(@lecturer.valid_password?('wrong_password')).to be_falsy
				res_body = JSON.parse(response.body)
				expect(res_body['errors']['current_password']).to_not be_empty
			end
		end
	end
end
