require 'rails_helper'

RSpec.describe V1::AssignmentsController, type: :controller do

  describe 'GET index' do

    before(:all) do
      @controller = V1::AssignmentsController.new
      @user = FactoryBot.build(:lecturer_with_units).process_new_record
      @user.save
      assignment1 = FactoryBot.create(:assignment, lecturer: @user, unit: @user.units.first)
      assignment2 = FactoryBot.create(:assignment, lecturer: @user, unit: @user.units.first)
      assignment3 = FactoryBot.create(:assignment, lecturer: @user, unit: @user.units.last)
      assignment_irrelevant = FactoryBot.create(:assignment)
    end

    before(:each) do
      mock_request = MockRequest.new(valid = true, @user)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
    end

    it 'returns all the assignments for the current user if no unit_id is provided', { docs?: true } do
      @assignment = FactoryBot.create(:assignment, lecturer: @user, unit: @user.units.first)
      iteration = create :iteration, assignment: @assignment
      pa_form = create :pa_form, iteration: iteration
      get :index
      expect(response.status).to eq(200)
      expect(parse_body['assignments'].length).to eq(4)
    end

    it 'returns all the assignments for the current unit if unit_id is provided and belongs to current user', { docs?: true } do
      get :index_with_unit, params: { unit_id: @user.units.first.id }
      expect(response.status).to eq(200)
      expect(parse_body['assignments'].length).to eq(2)
    end

    it 'responds with 403 forbidden if the user is a student and unit_id is present in the params' do
      @user = FactoryBot.build(:student_with_password).process_new_record
      @user.save
      unit = FactoryBot.create(:unit)
      mock_request = MockRequest.new(valid = true, @user)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

      get :index_with_unit, params: { unit_id: unit.id }
      expect(status).to eq(403)
      expect(body['errors']['base'][0]).to include('You must be Lecturer to access this resource')
    end

    it 'index responds with 204 if no assignments' do
      lecturer = create :lecturer_confirmed
      mock_request = MockRequest.new(valid = true, lecturer)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

      get :index

      expect(status).to eq 204
    end

    it 'index_with_unit retruns 204 if the unit has not assignments' do
      unit = create :unit, lecturer: @user
      expect(unit.assignments.count).to eq(0)
      expect(unit.lecturer).to eq @user

      get :index_with_unit, params: { unit_id: unit.id }

      expect(status).to eq(204)
    end

    it 'index_with_unit returns 204 if the unit does not belong to lecturer' do
      unit = create :unit
      assignment = create :assignment, unit: unit, lecturer: unit.lecturer
      expect(unit.assignments.count).to eq 1
      expect(unit.lecturer_id).to_not eq @user.id

      get :index_with_unit, params: { unit_id: unit.id }

      expect(status).to eq 204
    end
  end

  describe 'GET show' do

    context 'lecturer' do

      before(:all) do
        @controller = V1::AssignmentsController.new
        @user_w = FactoryBot.build(:lecturer_with_units).process_new_record
        @user_w.save
        @user_w.confirm
        @assignment1 = FactoryBot.create(:assignment, lecturer: @user_w, unit: @user_w.units.first)
        @assignment2 = FactoryBot.create(:assignment, lecturer: @user_w, unit: @user_w.units.first)
        @assignment3 = FactoryBot.create(:assignment, lecturer: @user_w, unit: @user_w.units.last)
        @assignment_irrelevant = FactoryBot.create(:assignment)
      end

      before(:each) do
        mock_request = MockRequest.new(valid = true, @user_w)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
      end

      it 'returns assignment if it belongs to current_user', { docs?: true } do
        get :show, params: { id: @assignment3.id, includes: 'unit' }
        expect(response.status).to eq(200)
        expect(parse_body['assignment']['id']).to eq(@assignment3.id)
      end

      it 'responds with 403 forbidden if th unit_id does not belong to current user' do
        get :show, params: { id: @assignment_irrelevant }
        expect(response.status).to eq(403)
        expect(parse_body['errors']['base'].first).to eq("This Assignment is not associated with the current user")
      end
    end
  end

  describe 'DELETE destroy' do

    context 'lecturer' do

      before(:all) do
        @controller = V1::AssignmentsController.new
        @user = FactoryBot.build(:lecturer_with_units).process_new_record
        @user.save
        @assignment1 = FactoryBot.create(:assignment, lecturer: @user, unit: @user.units.first)
        @assignment2 = FactoryBot.create(:assignment, lecturer: @user, unit: @user.units.first)
        @assignment3 = FactoryBot.create(:assignment, lecturer: @user, unit: @user.units.last)
        @assignment_irrelevant = FactoryBot.create(:assignment)
      end

      before(:each) do
        mock_request = MockRequest.new(valid = true, @user)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
      end

      it 'returns assignment if it belongs to current_user' do
        expect {
          delete :destroy, params: { id: @assignment3.id }
        }.to change { Assignment.all.length }.by(-1)
        expect(response.status).to eq(204)
      end

      it 'responds with 403 forbidden if th unit_id does not belong to current user' do
        expect {
          delete :destroy, params: { id: @assignment_irrelevant }
        }.to_not change { Assignment.all.length }
        expect(response.status).to eq(403)
        expect(parse_body['errors']['base'].first).to eq("This Assignment is not associated with the current user")
      end
    end

    context 'student' do
      it 'only the lecturer who created the assignment can destroy it' do
        @controller = V1::AssignmentsController.new
        @user = FactoryBot.build(:student_with_password).process_new_record
        @user.save
        mock_request = MockRequest.new(valid = true, @user)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
        expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
        expect(request.headers['X-XSRF-TOKEN']).to be_truthy
        assignment = FactoryBot.create(:assignment)

        expect{
          delete :destroy, params: { id: assignment.id }
        }.to_not change { Assignment.all.length }
        expect(response.status).to eq(403)
        expect(parse_body['errors']['base'].first).to include("You must be Lecturer to access this resource")
      end
    end
  end
end
