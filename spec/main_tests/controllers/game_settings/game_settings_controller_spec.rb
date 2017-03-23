require 'rails_helper'

RSpec.describe V1::GameSettingsController, type: :controller do

  before(:all) do
    @user = FactoryGirl.create(:lecturer)
    @unit = create :unit, lecturer: @user
    @assignment = create :assignment, lecturer: @user
    @game_settings = create :game_setting, assignment_id: @assignment.id
  end

  before(:each) do
    @controller = V1::GameSettingsController.new
    mock_request = MockRequest.new(valid = true, @user)
    request.cookies['access-token'] = mock_request.cookies['access-token']
    request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
  end

  describe 'GET show' do
    it 'returns game settings if current user is the assignment owner' do
      expect(@assignment.game_setting).to be_truthy
      get :index, params: { assignment_id: @assignment.id }

      expect(status).to eq 200
      expect(body['game_settings']['id']).to eq @game_settings.id
    end

    it 'returns 204 if not game settings exist' do
      assignment = create :assignment, lecturer: @user
      expect(assignment.game_setting).to be_falsy

      get :index, params: { assignment_id: assignment.id }

      expect(status).to eq 204
    end

    it 'returns 403 if the current user is a student' do
      @student = create :student

      @controller = V1::GameSettingsController.new
      mock_request = MockRequest.new(valid = true, @student)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

      get :index, params: { assignment_id: 1 }

      expect(status).to eq 403
      expect(body['errors']['base'][0]).to include('Lecturer to access')
    end

    it 'returns 403 if the current user is not associated with the assignement' do
      wrong_assignment = create :assignment
      get :index, params: { assignment_id: wrong_assignment.id }

      expect(status).to eq 403
      expect(errors['base'][0]).to include('not associated')
    end

    it 'returns 403 if the project does not exist in database' do
      wrong_id = 373733
      expect { GameSetting.find(wrong_id) }.to raise_error ActiveRecord::RecordNotFound

      get :index, params: { assignment_id: wrong_id }

      expect(status).to eq 403
      expect(errors['base'][0]).to include('not associated')
    end
  end


  describe 'POST create' do

    before :each do
      @assignment1 = create :assignment, lecturer: @user
    end

    it 'returns 201 if only assignment_id is provided' do
      post :create, params: { assignment_id: @assignment1.id }

      expect(status).to eq 201
      expect(body['game_settings']['points_log']).to be_truthy
      expect(body['game_settings']['assignment_id']).to eq @assignment1.id
    end

    it 'returns 201 if all parameters are present and does not have the default values' do
      parameters = attributes_for(:game_setting).merge({ assignment_id: @assignment1.id })

      post :create, params: parameters

      expect(status).to eq 201

      par = {}
      parameters.each { |key,val| par[key.to_s] = val }
      expect(body['game_settings'].except('id')).to eq par
    end

    it 'returns 422 if one parameter is not an integer' do
      parameters = attributes_for(:game_setting).merge({ assignment_id: @assignment1.id, points_log: 'wrong' })

      post :create, params: parameters

      expect(status).to eq 422
      expect(errors['points_log'][0]).to include 'not a number'
    end

    it 'returns 403 if the assignment_id does not belong to the lecturer' do
      wrong_assignment = create :assignment
      parameters = attributes_for(:game_setting).merge({ assignment_id: wrong_assignment.id })

      post :create, params: parameters

      expect(status).to eq 403
      expect(errors_base[0]).to include 'not associated'
    end

    it 'returns 403 if the current user is not a lecturer' do
      @student = create :student

      @controller = V1::GameSettingsController.new
      mock_request = MockRequest.new(valid = true, @student)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

      post :create, params: { assignment_id: 1 }

      expect(status).to eq 403
      expect(errors_base[0]).to include('Lecturer to access')
    end

    it 'returns 403 if the assignment already has game settings' do
      parameters = attributes_for(:game_setting).merge({ assignment_id: @assignment.id })

      post :create, params: parameters

      expect(status).to eq 403
      expect(errors['assignment_id'][0]).to include 'already'
    end
  end


  describe 'PATCH update' do
    it 'returns 200 and the new assignment if assignment_id belongs to the user and at least one parameter is present' do
      points = 90
      parameters = attributes_for(:game_setting).merge({ assignment_id: @assignment.id,
                                                         id: @assignment.game_setting.id,
                                                         points_log: points })

      patch :update, params: parameters

      expect(status).to eq 200
      expect(body['game_settings']['id']).to eq @assignment.game_setting.id
      expect(body['game_settings']['points_log']).to eq points
    end

    it 'returns 403 if lecturer is not the owner of the assignment' do
      assignment_other = create :assignment
      points = 90
      parameters = attributes_for(:game_setting).merge({ assignment_id: assignment_other.id,
                                                         id: 4,
                                                         points_log: points })

      patch :update, params: parameters

      expect(status).to eq 403
      expect(errors_base[0]).to include 'not associated'
    end

    it 'returns 403 if the id does not match the id of the assignments game_setting' do
      points = 90
      wrong_id = 474373
      expect(@assignment.game_setting.id).to_not eq wrong_id
      parameters = attributes_for(:game_setting).merge({ assignment_id: @assignment.id,
                                                         id: wrong_id,
                                                         points_log: points })

      patch :update, params: parameters

      expect(status).to eq 403
      expect(errors_base[0]).to include 'does not match'
    end

    it 'returns 403 if current user is not a lecturer' do
      @student = create :student

      @controller = V1::GameSettingsController.new
      mock_request = MockRequest.new(valid = true, @student)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

      patch :update, params: { assignment_id: 1, id: 3 }

      expect(status).to eq 403
      expect(body['errors']['base'][0]).to include('Lecturer to access')
    end

    it 'returns 422 if one of the parameters is not an integer' do
      parameters = attributes_for(:game_setting).merge({ assignment_id: @assignment.id,
                                                         id: @assignment.game_setting.id,
                                                         points_log: 'wrong' })

      patch :update, params: parameters

      expect(status).to eq 422
      expect(errors['points_log'][0]).to include 'not a number'
    end
  end
end
