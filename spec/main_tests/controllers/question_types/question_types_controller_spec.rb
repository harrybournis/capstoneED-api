require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::QuestionTypesController, type: :controller do

  describe 'GET /question_types' do

  	before :all do
  		@lecturer = create :lecturer_confirmed
  		create :question_type
  		create :question_type
  		create :question_type
  	end

  	before :each do
			@controller = V1::QuestionTypesController.new
  	end

    it 'returns question types if authenticated', { docs?: true } do
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

    	get :index

    	expect(status).to eq(200)
    	expect(body['question_types'].length).to eq 3
    end

    it 'returns 401 if not authenticated' do
    	get :index

    	expect(status).to eq 401
    end
  end
end
