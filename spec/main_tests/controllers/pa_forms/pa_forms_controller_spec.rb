require 'rails_helper'

RSpec.describe V1::PaFormsController, type: :controller do

	before(:all) do
		@lecturer = build(:lecturer_with_password).process_new_record
		@lecturer.save
		@lecturer.confirm
		@unit = create(:unit, lecturer: @lecturer)
		@assignment = create(:assignment, lecturer: @lecturer, unit: @unit)
		@iteration = create(:iteration, assignment: @assignment)
	end

	describe 'Lecturer' do
		before(:each) do
			@controller = V1::PaFormsController.new
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		it 'GET show returns the PAForm if associated with current user', { docs?: true } do
			pa_form = create(:pa_form, iteration: @iteration)
			get :show, params: { id: pa_form.id }
			expect(status).to eq(200)
			expect(body['pa_form']['id']).to eq(pa_form.id)
		end

		it 'GET show responds with 403 forbidden if the project is not associated with current user' do
			pa_form = create(:pa_form)
			get :show, params: { id: pa_form.id }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated')
		end

		it 'POST create responds with 201 if correct params', { docs?: true } do
			type1 = create :question_type
			type2 = create :question_type
			post :create, params: { iteration_id: @iteration.id,
															questions: [{ 'text' => 'Who is it?', 'type_id' => type2.id },
																					{ 'text' => 'Human?', 'type_id' => type2.id },
																					{ 'text' => 'Hello?', 'type_id' => type1.id },
																					{ 'text' => 'Favorite Power Ranger?', 'type_id' => type2.id }],
															start_date: @iteration.deadline + 1.day.to_i,
															deadline: @iteration.deadline + 3.days.to_i }

			expect(status).to eq(201)
			expect(body['pa_form']['questions']).to eq([{ "question_id" => 1, "text" => 'Who is it?', 'type_id' => "#{type2.id}" },
																									{ "question_id" => 2, "text" => 'Human?', 'type_id' => "#{type2.id}" },
																									{ "question_id" => 3, "text" => 'Hello?', 'type_id' => "#{type1.id}" },
																									{ "question_id" => 4, "text" => 'Favorite Power Ranger?', 'type_id' => "#{type2.id}" }])
		end

		it 'POST create saves the question if it is new' do
			type1 = create :question_type
			type2 = create :question_type

			expect {
			post :create, params: { iteration_id: @iteration.id,
															questions: [{ 'text' => 'Who is it?', 'type_id' => type2.id },
																					{ 'text' => 'Human?', 'type_id' => type2.id },
																					{ 'text' => 'Hello?', 'type_id' => type1.id },
																					{ 'text' => 'Favorite Power Ranger?', 'type_id' => type2.id }],
															start_date: @iteration.deadline + 1.day.to_i,
															deadline: @iteration.deadline + 3.days.to_i }
			}.to change { Question.all.count }.by 4

			expect(status).to eq(201)
		end

		it 'POST create responds with 422 unprocessable entity if questions not in correct form', { docs?: true } do
			post :create, params: { iteration_id: @iteration.id, questions: { questions: ['Who is it?', 'Human?'] } }
			expect(status).to eq(422)

			post :create, params: { iteration_id: @iteration.id, questions: 'Who is it?' }
			expect(status).to eq(422)
			expect(errors['questions'][0]).to include("can't be blank")
		end

		it "POST create responds with 403 forbidden if iteration_id in not from one of lecturer's projects" do
			iteration = create(:iteration)
			post :create, params: { iteration_id: iteration.id, questions: ['Who is it?', 'Human?', 'Hello?', 'Favorite Power Ranger?'] }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated')
		end

		describe 'POST create_for_each_iteration' do
			before :each do
				@type1 = create :question_type
				@type2 = create :question_type
			end

			it 'responds with 201 if successful', { docs?: true } do
				assignment = create(:assignment, lecturer: @lecturer, unit: @unit)
				iteration1 = create :iteration, assignment: assignment
				iteration2 = create :iteration, assignment: assignment
				expect(assignment.iterations.count).to eq 2
				expect(iteration1.pa_form).to be_falsy
				expect(iteration2.pa_form).to be_falsy

				expect {
					post :create_for_each_iteration, params: { assignment_id: assignment.id, questions: [{ 'text' => 'Who is it?', 'type_id' => @type2.id },
																							{ 'text' => 'Human?', 'type_id' => @type2.id },
																							{ 'text' => 'Hello?', 'type_id' => @type1.id },
																							{ 'text' => 'Favorite Power Ranger?', 'type_id' => @type2.id }],
																	start_offset: 1.day.to_i,
																	end_offset: 3.days.to_i }
				}.to change { PaForm.count }.by assignment.iterations.count

				expect(status).to eq 201
				iteration1.reload
				iteration2.reload
				expect(iteration1.pa_form).to be_truthy
				expect(iteration2.pa_form).to be_truthy
			end

			it 'responds with 422 if error in the form' do
				assignment = create(:assignment, lecturer: @lecturer, unit: @unit)
				iteration1 = create :iteration, assignment: assignment
				iteration2 = create :iteration, assignment: assignment
				expect(assignment.iterations.count).to eq 2
				expect(iteration1.pa_form).to be_falsy
				expect(iteration2.pa_form).to be_falsy

				expect {
					post :create_for_each_iteration, params: { assignment_id: assignment.id, questions: [{ 'text' => 'Who is it?', 'type_id' => @type2.id },
																							{ 'text' => 'Human?', 'type_id' => @type2.id },
																							{ 'text' => 'Hello?', 'type_id' => @type1.id },
																							{ 'text' => 'Favorite Power Ranger?', 'type_id' => @type2.id }],
																	end_offset: 3.days.to_i }
				}.to_not change { PaForm.count }

				expect(status).to eq 422
				expect(iteration1.pa_form).to be_falsy
				expect(iteration2.pa_form).to be_falsy
			end

			it 'responds with 422 if assignment does not have iterations' do
				assignment = create(:assignment, lecturer: @lecturer, unit: @unit)
				expect(assignment.iterations.count).to eq 0

				expect {
					post :create_for_each_iteration, params: { assignment_id: assignment.id, questions: [{ 'text' => 'Who is it?', 'type_id' => @type2.id },
																							{ 'text' => 'Human?', 'type_id' => @type2.id },
																							{ 'text' => 'Hello?', 'type_id' => @type1.id },
																							{ 'text' => 'Favorite Power Ranger?', 'type_id' => @type2.id }],
																	start_offset: 1.day.to_i,
																	end_offset: 3.days.to_i }
				}.to_not change { PaForm.count }

				expect(status).to eq 422
				expect(errors_base[0]).to include 'Iterations'
			end

			it 'responds with 422 if at least one iteration already has a pa_form' do
				assignment = create(:assignment, lecturer: @lecturer, unit: @unit)
				iteration1 = create :iteration, assignment: assignment
				iteration2 = create :iteration, assignment: assignment
				pa_form = create :pa_form, iteration: iteration1
				expect(assignment.iterations.count).to eq 2
				expect(iteration1.pa_form).to be_truthy

				expect {
					post :create_for_each_iteration, params: { assignment_id: assignment.id, questions: [{ 'text' => 'Who is it?', 'type_id' => @type2.id },
																							{ 'text' => 'Human?', 'type_id' => @type2.id },
																							{ 'text' => 'Hello?', 'type_id' => @type1.id },
																							{ 'text' => 'Favorite Power Ranger?', 'type_id' => @type2.id }],
																	start_offset: 1.day.to_i,
																	end_offset: 3.days.to_i }
				}.to_not change { PaForm.count }

				expect(status).to eq 422
				expect(iteration1.pa_form).to be_truthy
				expect(iteration2.pa_form).to be_falsy
				expect(errors_base[0]).to include 'already'
			end

			it 'responds with 403 if assignment does not belong to user' do
				assignment = create(:assignment)
				iteration1 = create :iteration, assignment: assignment
				expect(iteration1.pa_form).to be_falsy

				expect {
					post :create_for_each_iteration, params: { assignment_id: assignment.id, questions: [{ 'text' => 'Who is it?', 'type_id' => @type2.id },
																							{ 'text' => 'Human?', 'type_id' => @type2.id },
																							{ 'text' => 'Hello?', 'type_id' => @type1.id },
																							{ 'text' => 'Favorite Power Ranger?', 'type_id' => @type2.id }],
																	end_offset: 3.days.to_i }
				}.to_not change { PaForm.count }

				expect(status).to eq 403
				expect(iteration1.pa_form).to be_falsy
				expect(errors_base[0]).to include 'associated'
			end

			it 'responds with 403 if current user is a student' do
				student = create :student_confirmed

				@controller = V1::PaFormsController.new
				mock_request = MockRequest.new(valid = true, student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

				expect {
					post :create_for_each_iteration, params: { assignment_id: @assignment.id, questions: [{ 'text' => 'Who is it?', 'type_id' => @type2.id },
																							{ 'text' => 'Human?', 'type_id' => @type2.id },
																							{ 'text' => 'Hello?', 'type_id' => @type1.id },
																							{ 'text' => 'Favorite Power Ranger?', 'type_id' => @type2.id }],
																	end_offset: 3.days.to_i }
				}.to_not change { PaForm.count }

				expect(errors_base[0]).to include 'Lecturer'
			end
		end

		# it 'PATCH update responds with 201 if correct params' do
		# 	pa_form = create(:pa_form, iteration: @iteration)
		# 	patch :update, params: { id: pa_form.id, questions: ['new Who is it?', 'Human?', 'new Hello?', 'Favorite Power Ranger?'] }
		# 	expect(status).to eq(200)
		# 	expect(body['pa_form']['questions']).to eq([{ "question_id" => 1, "text" => 'new Who is it?' }, { "question_id" => 2, "text" => 'Human?' }, { "question_id" => 3, "text" => 'new Hello?' }, { "question_id" => 4, "text" => 'Favorite Power Ranger?' }])
		# end

		# it 'PATCH update responds with 422 unprocessable entity if questions not in correct form' do
		# 	pa_form = create(:pa_form, iteration: @iteration)
		# 	pa_form_wrong = create(:pa_form)
		# 	patch :update, params: { id: pa_form_wrong.id, questions: { questions: ['Who is it?', 'Human?'] } }
		# 	expect(status).to eq(403)

		# 	post :create, params: { id: pa_form.id, iteration_id: @iteration.id, questions: 'Who is it?' }
		# 	expect(status).to eq(422)
		# 	expect(errors['questions'][0]).to include("can't be blank")
		# end

		# it 'DELETE destroy responds with 204 no content if lecturer is owner' do
		# 	pa_form = create(:pa_form, iteration: @iteration)
		# 	delete :destroy, params: { id: pa_form.id }
		# 	expect(status).to eq(204)
		# end
	end


	describe 'Student' do

		before(:each) do
			@controller = V1::PaFormsController.new
			@student = create :student_confirmed
			@project = create(:project, assignment_id: @assignment.id)
			create :students_project, student: @student, project: @project
			mock_request = MockRequest.new(valid = true, @student)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		it 'GET index returns the active PAForms', { docs?: true, lecturer?: false } do
			now = DateTime.now
			iteration1 = create(:iteration, start_date: now + 3.days, deadline: now + 5.days, assignment_id: @assignment.id)
			iteration2 = create(:iteration, start_date: now + 4.days, deadline: now + 6.days, assignment_id: @assignment.id)
			create(:pa_form, iteration: iteration1, start_offset: 2.days.to_i, end_offset: 5.days.to_i)
			create(:pa_form, iteration: iteration2, start_offset: 2.days.to_i, end_offset: 5.days.to_i)
			irrelevant = create(:pa_form)
			expect(PaForm.all.length).to eq 3

			Timecop.travel(now + 5.days + 1.minute) do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index
				expect(status).to eq 204
			end

			Timecop.travel(now + 5.days + 2.days + 1.minute) do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index
				expect(status).to eq 200
				expect(body['pa_forms'].length).to eq(1)
			end

			Timecop.travel(now + 6.days + 2.days + 1.minute) do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index
				expect(status).to eq 200
				expect(body['pa_forms'].length).to eq(2)
			end

			Timecop.travel(now + 6.days + 5.days + 1.minute) do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index
				expect(status).to eq 204
			end
		end

		it 'GET index returns the active PAForms that have not been submitted by the student' do
			now = DateTime.now
			iteration1 = create(:iteration, start_date: now + 3.days, deadline: now + 5.days, assignment_id: @assignment.id)
			iteration2 = create(:iteration, start_date: now + 4.days, deadline: now + 6.days, assignment_id: @assignment.id)
			create(:pa_form, iteration: iteration1)
			pa_form = create(:pa_form, iteration: iteration2)
			irrelevant = create(:pa_form)
			expect(PaForm.all.length).to eq 3

			Timecop.travel(now + 5.days + 1.minute) do
				@other_student = create :student_confirmed
				create :students_project, project: @project, student: @other_student
				create :peer_assessment, submitted_for: @other_student, submitted_by: @student, pa_form: pa_form

				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index

				expect(status).to eq 204
			end
		end

		it 'GET index returns the active PAForms with questions types', { docs?: true, lecturer?: false } do
			now = DateTime.now
			iteration1 = create(:iteration, start_date: now + 3.days, deadline: now + 5.days, assignment_id: @assignment.id)
			iteration2 = create(:iteration, start_date: now + 4.days, deadline: now + 6.days, assignment_id: @assignment.id)
			pa_form1 = create(:pa_form, iteration: iteration1)
			create(:pa_form, iteration: iteration2)
			irrelevant = create(:pa_form)
			expect(PaForm.all.length).to eq 3

			Timecop.travel(pa_form1.start_date + 1.minute) do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index
				expect(status).to eq 200
				expect(body['pa_forms'].length).to eq(1)
				body['pa_forms'][0]['questions'].each do |q|
					expect(q.keys).to include 'question_type'
				end
			end
		end

		it 'GET index contains the project_id' do
			now = DateTime.now
			iteration1 = create(:iteration, start_date: now + 3.days, deadline: now + 5.days, assignment_id: @assignment.id)
			iteration2 = create(:iteration, start_date: now + 4.days, deadline: now + 6.days, assignment_id: @assignment.id)
			pa_form1 = create(:pa_form, iteration: iteration1)
			create(:pa_form, iteration: iteration2)
			irrelevant = create(:pa_form)
			expect(PaForm.all.length).to eq 3

			Timecop.travel(pa_form1.start_date + 1.minute) do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index
				expect(status).to eq 200
				expect(body['pa_forms'].length).to eq(1)
				projects = @student.projects
				iteration_assignment = Iteration.where(id: body['pa_forms'][0]['iteration_id'])[0].assignment
				project = projects.where(assignment_id: @assignment.id)[0]
				@assignment.projects.includes(:students).where(student_id: @student.id)
				expect(body['pa_forms'][0]['project_id']).to eq project.id
			end
		end

		it 'GET index contains the project_id and makes queries' do
			now = DateTime.now
			iteration1 = create(:iteration, start_date: now + 3.days, deadline: now + 5.days, assignment_id: @assignment.id)
			iteration2 = create(:iteration, start_date: now + 4.days, deadline: now + 6.days, assignment_id: @assignment.id)
			pa_form1 = create(:pa_form, iteration: iteration1)
			create(:pa_form, iteration: iteration2)
			irrelevant = create(:pa_form)
			expect(PaForm.all.length).to eq 3

			Timecop.travel(pa_form1.start_date + 1.minute) do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				expect {
					get :index
				}.to make_database_queries(count: 7)
				expect(status).to eq 200
				expect(body['pa_forms'].length).to eq(1)
				projects = @student.projects
				iteration_assignment = Iteration.where(id: body['pa_forms'][0]['iteration_id'])[0].assignment
				project = projects.where(assignment_id: @assignment.id)[0]
				@assignment.projects.includes(:students).where(student_id: @student.id)
				expect(body['pa_forms'][0]['project_id']).to eq project.id
			end
		end

		it 'GET show returns the PAForm if associated with current user' do
			pa_form = create(:pa_form, iteration: @iteration)
			get :show, params: { id: pa_form.id }
			expect(status).to eq(200)
			expect(body['pa_form']['id']).to eq(pa_form.id)
		end

		it 'GET show responds with 403 forbidden if the project is not associated with current user' do
			pa_form = create(:pa_form)
			get :show, params: { id: pa_form.id }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated')
		end

		it 'GET index return with the extensions', { docs?: true, lecturer?: false } do
			now = DateTime.now
			iteration1 = create(:iteration, start_date: now + 3.days, deadline: now + 5.days, assignment_id: @assignment.id)
			iteration2 = create(:iteration, start_date: now + 4.days, deadline: now + 6.days, assignment_id: @assignment.id)
			iteration3 = create(:iteration, start_date: now + 4.days, deadline: now + 6.days + 1.hour, assignment_id: @assignment.id)
			pa_form = create(:pa_form, iteration: iteration1)
			pa_form2 = create(:pa_form, iteration: iteration2)
			irrelevant = create(:pa_form, iteration: iteration3)
			extension = create(:extension, project_id: @project.id, deliverable_id: pa_form2.id)
			expect(PaForm.all.length).to eq 4

			Timecop.travel(pa_form2.start_date + 1.minute) do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index
				expect(status).to eq 200
				expect(body['pa_forms'].length).to eq(2)
				expect(DateTime.parse(body['pa_forms'][1]['extension_until'])).to eq(pa_form2.deadline_with_extension_for_project(@project).to_datetime)
			end
		end
	end

end
