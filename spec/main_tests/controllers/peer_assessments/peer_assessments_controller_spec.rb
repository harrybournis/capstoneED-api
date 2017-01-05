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
			@assignment = FactoryGirl.create(:assignment)
			@project = FactoryGirl.create(:project, assignment: @assignment)
			@iteration = FactoryGirl.create(:iteration, assignment: @assignment)
			@project.students << @student_for
			@project.students << @student
			@project.students << FactoryGirl.create(:student_confirmed)
			@pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)

			@irrelevant_team = FactoryGirl.create(:project)
			@irrelevant_student = FactoryGirl.create(:student_confirmed)
			4.times { @irrelevant_team.students << FactoryGirl.create(:student_confirmed) }
			@irrelevant_team.students << @irrelevant_student
		end

		describe 'POST create' do
			it 'creates a new Peer Assessment for a certain user with submitted_by from the current_user', { docs?: true, lecturer?: false } do
				Timecop.travel(@pa_form.start_date + 1.minute) do
					@controller = V1::PeerAssessmentsController.new
					mock_request = MockRequest.new(valid = true, @student)
					request.cookies['access-token'] = mock_request.cookies['access-token']
					request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

					post :create, params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }
					expect(status).to eq(201)
					expect(body['peer_assessment']['submitted_by_id']).to eq(@student.id)
					expect(body['peer_assessment']['answers'][1]['answer']).to eq('I enjoyed the presentations')
				end
			end

			describe 'responds with 422 unprocessable_entity if' do
				it 'params are missing' do
					post :create, params: { pa_form_id: @pa_form.id, answers: [{ question_id: 3, answer: 'dkdk' }, { question_id: 2, answer: 'dsfdfsdsf' }] }
					expect(status).to eq(422)
				end

				it 'answers are not in correct format', { docs?: true, lecturer?: false } do
					post :create, params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for, answers: { question_id: 3, answer: 'dkdk', something: 'ddd' } }
					expect(status).to eq(422)
					expect(errors['answers'][0]).to include('is not an Array')
				end
			end
		end
	end

	context 'when current_user is Lecturer' do

		before :all do
			@unit = FactoryGirl.create(:unit, lecturer: @lecturer)
			@assignment = FactoryGirl.create(:assignment, lecturer: @lecturer, unit: @unit)
			@iteration = FactoryGirl.create(:iteration, assignment: @assignment)
			@pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)
			@student2 = FactoryGirl.create(:student_confirmed)
			@student3 = FactoryGirl.create(:student_confirmed)
			@student4 = FactoryGirl.create(:student_confirmed)
			@student5 = FactoryGirl.create(:student_confirmed)
			@project = FactoryGirl.create(:project, assignment: @assignment)
			@project.students << @student
			@project.students << @student2
			@project.students << @student3
			@project.students << @student4
			@project.students << @student5

			Timecop.travel(@iteration.start_date + 1.minute) do
				@peer_assessment = FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student2)
				FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student3)
				FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student4)
				FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student5)

				FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student)
				FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student3)
				FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student4)
				FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student5)
			end
		end

		before do
			@controller = V1::PeerAssessmentsController.new
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'GET index' do

			it 'shows all peer assessments for a PAForm if pa_form_id is in the params' do
				get :index, params: { pa_form_id: @pa_form.id }
				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@pa_form.peer_assessments.length)
			end

			it 'shows all peer assessments BY a Student if submitted_by is in the params', { docs?: true } do
				get :index, params: { pa_form_id: @pa_form.id, submitted_by_id: @student.id }
				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@student.peer_assessments_submitted_by.length)
				expect(body['peer_assessments'].length).to eq(4)
			end

			it 'shows all peer assessments FOR a Student if submitted_for is in the params', { docs?: true } do
				get :index, params: { pa_form_id: @pa_form.id, submitted_for_id: @student.id }
				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@student.peer_assessments_submitted_for.length)
				expect(body['peer_assessments'].length).to eq(1)
			end

			it 'responds with 400 bad request if no PAForm, submitted_by, submitted_for is present in the params', { docs?: true } do
				get :index
				expect(status).to eq(400)
				expect(errors['base'][0]).to include('no pa_form_id in the params')
			end

			it 'makes custom queries with project_id', { docs?: true } do
				get :index, params: { project_id: @project.id }

				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@project.peer_assessments.count)
			end


			it 'student shows all peer assessments BY a Student if submitted_by is in the params', { docs?: true, lecturer?: false } do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				get :index, params: { pa_form_id: @pa_form.id, submitted_by_id: @student.id }
				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@student.peer_assessments_submitted_by.length)
				expect(body['peer_assessments'].length).to eq(4)
			end

			it 'student shows all peer assessments FOR a Student if submitted_for is in the params', { docs?: true, lecturer?: false } do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				get :index, params: { pa_form_id: @pa_form.id, submitted_for_id: @student.id }
				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@student.peer_assessments_submitted_for.length)
				expect(body['peer_assessments'].length).to eq(1)
			end

			it 'student responds with 400 bad request if no PAForm, submitted_by, submitted_for is present in the params', { docs?: true, lecturer?: false } do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				get :index
				expect(status).to eq(400)
				expect(errors['base'][0]).to include('no pa_form_id in the params')
			end

			it 'student makes custom queries with project_id', { docs?: true, lecturer?: false } do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				get :index, params: { project_id: @project.id }

				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@project.peer_assessments.where(["submitted_by_id = ? or submitted_for_id = ?", @student.id, @student.id]).count)
			end


			it 'does not return the answers if current user is a Student' do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				get :index, params: { project_id: @project.id }

				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(PeerAssessment.where(['submitted_for_id = ? or submitted_by_id = ?', @student.id, @student.id]).where(project_id: @project.id).count)
				expect(body['peer_assessments'][0]['answers']).to be_falsy
			end

			it 'includes the answers if current user is a Lecturer' do
				get :index, params: { project_id: @project.id }

				expect(status).to eq(200)
				expect(body['peer_assessments'].length).to eq(@project.peer_assessments.count)
				expect(body['peer_assessments'][0]['answers']).to be_truthy
			end
		end

		describe 'GET show' do
			it 'returns peer assessment if associated', { docs?: true } do
				get :show, params: { id: @peer_assessment.id }
				expect(status).to eq(200)
			end

			it 'returns 403 forbiden if peer_assement not associated' do
				other = FactoryGirl.create(:peer_assessment)
				get :show, params: { id: other.id }
				expect(status).to eq(403)
				expect(errors['base'][0]).to include('not associated')
			end

			it 'does not return the answers if current user is a Student', { docs?: true, lecturer?: false } do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				get :show, params: { id: @student.peer_assessments_submitted_by[0].id }

				expect(status).to eq(200)
				expect(body['peer_assessment']['answers']).to be_falsy
			end
		end

		describe 'POST create' do
			it 'does not work for lecturers' do
				post :create, params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for, answers: [{ question_id: 3, answer: 'dkdk' }, { question_id: 2, answer: 'dsfdfsdsf' }] }
				expect(status).to eq(403)
				expect(errors['base'][0]).to include('must be Student')
			end
		end
	end

end
