require 'rails_helper'

RSpec.describe V1::Iterations::ScoredIterationsController, type: :controller do

  before(:each) do
    @controller = V1::Iterations::ScoredIterationsController.new
    @user = create(:lecturer_confirmed)
    mock_request = MockRequest.new(valid = true, @user)
    request.cookies['access-token'] = mock_request.cookies['access-token']
    request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

  end

  describe 'index' do
    it 'returns 200 and all the scored iterations chronologically with the date that it ended' do
      @unit = create(:unit, lecturer_id: @user.id)
      @assignment = create :assignment, unit: @unit, lecturer: @user
      3.times { create :iteration, assignment: @assignment }
      iteration_count = @user.iterations.count
      @user.iterations.first.update(is_scored: true)

      get :index

      expect(status).to eq(200)
      expect(body['iterations'].length).to eq  1
    end

    it 'returns 204 if no scored iterations' do
      @unit = create(:unit, lecturer_id: @user.id)
      @assignment = create :assignment, unit: @unit, lecturer: @user
      3.times { create :iteration, assignment: @assignment }
      iteration_count = @user.iterations.count

      get :index

      expect(status).to eq(204)
    end

    it 'returns the iterations in the order that they finished' do
      @unit = create(:unit, lecturer_id: @user.id)
      @assignment = create :assignment, unit: @unit, lecturer: @user
      now = DateTime.now
      iteration1 = create :iteration, assignment: @assignment, start_date: now, deadline: now + 2.days, is_scored: true
      iteration2 = create :iteration, assignment: @assignment, start_date: now + 3.days, deadline: now + 5.days, is_scored: true
      iteration3 = create :iteration, assignment: @assignment, start_date: now + 6.days, deadline: now + 8.days, is_scored: true

      get :index

      expect(status).to eq 200
      expect(body['iterations'].first['id']).to eq iteration3.id
      expect(body['iterations'].second['id']).to eq iteration2.id
      expect(body['iterations'].third['id']).to eq iteration1.id
    end
  end
end
