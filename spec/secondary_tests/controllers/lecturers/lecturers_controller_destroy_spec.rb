# require 'rails_helper'
# require 'helpers/mock_request.rb'
# include JWTAuth::JWTAuthenticator

# RSpec.describe 'V1::LecturersController DELETE /destroy', type: :controller do

# 	before(:each) do
# 		@controller = V1::UsersController.new
# 		@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
# 		@lecturer.save
# 		mock_request = MockRequest.new(valid = true, @lecturer)
# 		request.cookies['access-token'] = mock_request.cookies['access-token']
# 		request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
# 		expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
# 		expect(request.headers['X-XSRF-TOKEN']).to be_truthy
# 	end

# 	context 'valid request' do

# 		describe 'DELETE destroy' do
# 			it "deletes user from database" do
# 				delete :destroy, params: { id: @lecturer.id, current_password: '12345678' }
# 				expect(Lecturer.exists?(@lecturer.id)).to be_falsy
# 			end

# 			it 'changes the number of users in the database' do
# 				expect {
# 					delete :destroy, params: { id: @lecturer.id, current_password: '12345678' }
# 				}.to change{ Lecturer.all.count }.by(-1)
# 			end

# 			it 'returns 204 no content' do
# 				delete :destroy, params: { id: @lecturer.id, current_password: '12345678' }
# 				expect(response.status).to eq(204)
# 				expect(Lecturer.exists?(@lecturer.id)).to be_falsy
# 			end

# 			it 'requires password to complete delete' do
# 				expect(@lecturer.valid_password?('12345678')).to be_truthy
# 				delete :destroy, params: { id: @lecturer.id, current_password: '12345678' }
# 				expect(response.status).to eq(204)
# 			end

# 			it 'deletes all associated active tokens' do
# 				device = SecureRandom.base64(32)
# 				time_before = DateTime.now - 1.hour
# 				valid_token = FactoryGirl.create(:active_token, exp: time_before, device: SecureRandom.base64(32), user: @lecturer)
# 				valid_token2 = FactoryGirl.create(:active_token, exp: time_before, device: SecureRandom.base64(32), user: @lecturer)
# 				valid_token3 = FactoryGirl.create(:active_token, exp: time_before, device: SecureRandom.base64(32), user: @lecturer)

# 				expect {
# 					delete :destroy, params: { id: @lecturer.id, current_password: '12345678' }
# 				}.to change { ActiveToken.count }.by(-3)

# 				expect(Lecturer.exists?(@lecturer.id)).to be_falsy
# 			end
# 		end
# 	end

# 	context 'invalid request' do

# 		describe 'DELETE destroy' do
# 			it 'valid tokens are not deleted' do
# 				@controller = V1::UsersController.new
# 				@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
# 				@lecturer.save
# 				mock_request = MockRequest.new(valid = false, @lecturer)
# 				request.cookies['access-token'] = mock_request.cookies['access-token']
# 				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

# 				expect {
# 					delete :destroy, params: { id: @lecturer.id }
# 				}.to_not change { Lecturer.find(@lecturer.id).active_tokens.count }
# 				expect(Lecturer.exists?(@lecturer.id)).to be_truthy
# 			end

# 			it 'returns 401 if authentication problem' do
# 				@controller = V1::UsersController.new
# 				@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
# 				@lecturer.save
# 				mock_request = MockRequest.new(valid = false, @lecturer)
# 				request.cookies['access-token'] = mock_request.cookies['access-token']
# 				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

# 				expect { delete :destroy, params: { id: @lecturer.id, current_password: 'password' } }.to_not make_database_queries
# 				expect(response.status).to eq(401)
# 				expect(Lecturer.exists?(@lecturer.id)).to be_truthy
# 			end

# 			it 'returns 403 forbidden if the user to be deleted is not the current user' do
# 				different_user = FactoryGirl.create(:lecturer)
# 				old_name = different_user.first_name
# 				delete :destroy, params: { id: different_user.id, current_password: 'something' }

# 				expect(response.status).to eq(403)
# 				expect(Lecturer.exists?(different_user.id)).to be_truthy
# 			end

# 			it 'returns 422 unprocessable_entity if password is invalid' do
# 				delete :destroy, params: { id: @lecturer.id, current_password: 'qwertyuiop' }

# 				expect(Lecturer.exists?(@lecturer.id)).to be_truthy
# 				expect(response.status).to eq(422)
# 				expect(@lecturer.valid_password?('qwertyuiop')).to be_falsy
# 				expect(@lecturer.valid_password?('12345678')).to be_truthy
# 				res_body = JSON.parse(response.body)
# 				expect(res_body['errors']['current_password']).to include("is invalid")
# 			end
# 		end
# 	end
# end
