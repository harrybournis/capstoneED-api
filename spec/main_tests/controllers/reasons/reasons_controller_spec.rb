require 'rails_helper'

RSpec.describe V1::ReasonsController, type: :controller do

  before :all do
    @lecturer = create :lecturer_confirmed
    @student = create :student_confirmed
  end

  before :each do
    @controller = V1::ReasonsController.new
    mock_request = MockRequest.new(valid = true, @student)
    request.cookies['access-token'] = mock_request.cookies['access-token']
    request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
  end

  describe 'index' do
    it 'returns the all the reasons', { docs?: true } do
      get :index

      expect(status).to eq 200
      expect(body['reasons']).to be_truthy

      body['reasons'].each do |key,val|
        expect(val['id']).to be_truthy
        expect(val['description']).to be_truthy
      end
    end

    it 'fails if no user authenticated' do
      @controller = V1::ReasonsController.new
      mock_request = MockRequest.new(valid = false, @student)
      request.cookies['access-token'] = nil
      request.headers['X-XSRF-TOKEN'] = nil

      get :index

      expect(status).to eq 401
    end
  end
end
