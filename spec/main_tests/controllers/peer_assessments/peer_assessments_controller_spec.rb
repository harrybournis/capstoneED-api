require 'rails_helper'

RSpec.describe V1::PeerAssessmentsController, type: :controller do

	before :all do
		@student = FactoryGirl.create(:student_confirmed)
		@lecturer = FactoryGirl.create(:lecturer_confirmed)
	end

	context 'when current_user is Student' do
		before do
			@controller = V1::PeerAssessmentsController.new
			mock_request = MockRequest.new(valid = true, @student)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			@student_for = FactoryGirl.create(:student_confirmed)
			@pa_form = FactoryGirl.create(:pa_form)
		end

		describe 'POST create' do
			it 'creates a new Peer Assessment for a certain user with submitted_by from the current_user'
			it 'responds with 400 bad request if params are missing'
			it 'responds with 400 bad request if answers are not in correct format'
			it 'responds with 403 forbidden if PAForm deadline has passed'
		end
	end

	context 'when current_user is Lecturer' do

		before :all do
			@unit = FactoryGirl.create(:unit, lecturer: @lecturer)
			@project = FactoryGirl.create(:project, lecturer: @lecturer, unit: @unit)
			@iteration = FactoryGirl.create(:iteration, project: @project)
			@pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)
			@student2 = FactoryGirl.create(:student_confirmed)
			@student3 = FactoryGirl.create(:student_confirmed)
			@student4 = FactoryGirl.create(:student_confirmed)
			@student5 = FactoryGirl.create(:student_confirmed)

			FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student2)
			FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student3)
			FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student4)
			FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student5)

			FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student)
			FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student3)
			FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student4)
			FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student5)
		end

		before do
			@controller = V1::PeerAssessmentsController.new
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'GET index' do
			it 'shows all peer assessments for a PAForm if pa_form_id is in the params' do
				get :index_with_pa_form, params: { pa_form_id: @pa_form.id }
				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@pa_form.peer_assessments.length)
			end

			it 'shows all peer assessments BY a Student if submitted_by is in the params' do
				get :index_with_submitted_by, params: { submitted_by_id: @student.id }
				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@student.peer_assessments_submitted_by.length)
				expect(body['peer_assessments'].length).to eq(4)
			end

			it 'shows all peer assessments FOR a Student if submitted_for is in the params' do
				get :index_with_submitted_by, params: { submitted_by_id: @student.id }
				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@student.peer_assessments_submitted_by.length)
				expect(body['peer_assessments'].length).to eq(4)
			end

			it 'responds with 400 bad request if no PAForm, submitted_by, submitted_for is present in the params' do
				get :index
				expect(status).to eq(403)
				expect(errors['base'][0]).to include('There was no pa_form_id, submitted_by_id, or submitted_for_id in the params. Retry with one of those')
			end
		end

		describe 'GET show' do
			it 'returns peer assessment if associated'
		end
	end

end
