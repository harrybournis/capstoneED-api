require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::ExtensionsController, type: :controller do

	before(:all) do
		@lecturer = get_lecturer_with_units_assignments_projects
	end

	before(:each) do
		@controller = V1::ExtensionsController.new
		mock_request = MockRequest.new(valid = true, @lecturer)
		request.cookies['access-token'] = mock_request.cookies['access-token']
		request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
	end

	describe 'POST /extensions' do
		it 'creates new extension' do
			assignment = @lecturer.assignments[0]
			iteration = FactoryGirl.create(:iteration, assignment_id: assignment.id)
			pa_form = FactoryGirl.create(:pa_form, iteration_id: iteration.id)
			project = assignment.projects[0]
			time = 2.days.to_i
			expect {
				post :create, params: { deliverable_id: pa_form.id, project_id: project.id, extra_time: time.to_i }
			}.to change { Extension.count }.by(1)
			expect(status).to eq(201)
			expect(Extension.last.extra_time).to eq(time.to_i)

		end

		it 'responds with 403 forbidden if project or iteration are not associated with current lecturer' do
			iteration = FactoryGirl.create(:iteration, assignment_id: @lecturer.assignments[0].id)
			pa_form = FactoryGirl.create(:pa_form, iteration_id: iteration.id)
			project = FactoryGirl.create(:project)
			expect {
				post :create, params: { deliverable_id: pa_form.id, project_id: project.id, extra_time: DateTime.now + 2.days }
			}.to_not change { Extension.count }
			expect(status).to eq(403)
		end
	end

	describe 'PATCH /extensions' do
		it 'updates the extra time' do
			assignment = @lecturer.assignments[0]
			iteration = FactoryGirl.create(:iteration, assignment_id: assignment.id)
			pa_form = FactoryGirl.create(:pa_form, iteration_id: iteration.id)
			project = assignment.projects[0]
			time = 3.days.to_i
			extension = FactoryGirl.create(:extension, project_id: project.id, deliverable_id: pa_form.id)
			patch :update, params: { id: extension.id, project_id: project.id, extra_time: time }
			expect(status).to eq(200)

			extension.reload
			expect( extension.extra_time).to eq(time)
		end

		it 'returns 403 if team extension not associated with current lecturer' do
			assignment = @lecturer.assignments[0]
			iteration = FactoryGirl.create(:iteration, assignment_id: assignment.id)
			project = FactoryGirl.create(:project)
			time = 3.days.to_i
			extension = FactoryGirl.create(:extension)
			patch :update, params: { id: extension.id, project_id: project.id, extra_time: time }
			expect(status).to eq(403)
		end
	end

	describe 'DELETE /extensions' do
		it 'deletes extension' do
			assignment = @lecturer.assignments[0]
			iteration = FactoryGirl.create(:iteration, assignment_id: assignment.id)
			pa_form = FactoryGirl.create(:pa_form, iteration_id: iteration.id)
			project = assignment.projects[0]
			time = 3.days.to_i
			extension = FactoryGirl.create(:extension, project_id: project.id, deliverable_id: pa_form.id)
			expect {
				delete :destroy, params: { id: extension.id, project_id: project.id }
			}.to change { Extension.count }.by(-1)
		end

		it 'returns 403 if team extension not associated with current lecturer' do
			assignment = @lecturer.assignments[0]
			iteration = FactoryGirl.create(:iteration, assignment_id: assignment.id)
			project = FactoryGirl.create(:project)
			time = 3.days.to_i
			extension = FactoryGirl.create(:extension)
			delete :destroy, params: { id: extension.id, project_id: project.id, extra_time: time }
			expect(status).to eq(403)
		end
	end
end
