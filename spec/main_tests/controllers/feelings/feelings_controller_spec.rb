require 'rails_helper'

RSpec.describe V1::FeelingsController, type: :controller do

	before(:all) { @user = FactoryGirl.create :student }

	before(:each) do
		@controller = V1::FeelingsController.new
		mock_request = MockRequest.new(valid = true, @user)
		request.cookies['access-token'] = mock_request.cookies['access-token']
		request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
	end

	it 'index returns all feelings', { docs?: true } do
		FactoryGirl.create_list(:feeling, 3)
		get :index

		expect(status).to eq(200)
		expect(body['feelings'].length).to eq(Feeling.all.length)
		expect(body['feelings'][0]['name']).to be_truthy
	end
end
