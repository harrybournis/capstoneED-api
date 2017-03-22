require 'rails_helper'

RSpec.describe V1::GameSettingsController, type: :controller do

  before(:all) { @user = FactoryGirl.create(:lecturer) }

  before(:each) do
    @controller = V1::GameSettingsController.new
    mock_request = MockRequest.new(valid = true, @user)
    request.cookies['access-token'] = mock_request.cookies['access-token']
    request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
  end

  describe 'GET show' do
    it 'returns game settings if current user is the assignment owner'

    it 'returns 401 if the current user is a student'

    it 'returns 401 if the current user is not associated with the assignemnt'

    it 'returns 401  if the project does not exist in database'
  end

  describe 'POST create' do
    it 'POST create returns 201 if only assignment_id is provided'

    it 'POST create returns 201 if all parameters are present and does not have the default values'

    it 'POST create returns 422 assignment_id is missing'

    it 'POST create returns 422 if one parameter is not an integer'

    it 'POST create returns 401 if the assignment_id does not belong to the lecturer'

    it 'POST create returns 401 if the current user is not a lecturer'

    it 'POST create returns 403 if the assignment already has game settings'
  end

  describe 'PATCH update' do
    it 'PATCH update returns 200 and the new assignment if assignment_id belongs to the user and at least one parameter is present'

    it 'PATCH update returns 204 if only assignment_id exists in params'

    it 'PATCH update returns 401 if lecturer is not the owner of the assignment'

    it 'PATCH update returns 401 if current user is not a lecturer'

    it 'PATCH update returns 422 if one of the parameters is not an integer'
  end
end
