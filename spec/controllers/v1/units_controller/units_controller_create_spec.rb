require 'rails_helper'

RSpec.describe V1::UnitsController, type: :controller do

	describe 'POST create' do

		before(:each) do
			#@controller = V1::UnitsController.new
			@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
			@lecturer.save
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
			expect(request.headers['X-XSRF-TOKEN']).to be_truthy
		end

		it 'must be a lecturer to create a Unit' do
			post :create, params: FactoryGirl.attributes_for(:unit)
			expect(response.status).to eq(201)
		end

		it 'creates a department'

	end
end
