require 'rails_helper'

RSpec.describe V1::PAFormsController, type: :controller do

	before(:all) do
		@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
		@lecturer.save
		@lecturer.confirm
		@unit = FactoryGirl.create(:unit, lecturer: @lecturer)
		@project = FactoryGirl.create(:project, lecturer: @lecturer, unit: @unit)
		@iteration = FactoryGirl.create(:iteration, project_id: @project.id)
	end

	describe 'Lecturer' do
		before(:each) do
			@controller = V1::PAFormsController.new
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		it 'GET show returns the PAForm if associated with current user' do
			pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)
			get :show, params: { id: pa_form.id }
			expect(status).to eq(200)
			expect(body['pa_form']['id']).to eq(pa_form.id)
		end

		it 'GET show responds with 403 forbidden if the project is not associated with current user' do
			pa_form = FactoryGirl.create(:pa_form)
			get :show, params: { id: pa_form.id }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated')
		end

		it 'POST create responds with 201 if correct params' do
			post :create, params: { iteration_id: @iteration.id, questions: ['Who is it?', 'Human?', 'Hello?', 'Favorite Power Ranger?'], start_date: DateTime.now + 1.day, deadline: DateTime.now + 2.days }
			expect(status).to eq(201)
			expect(body['pa_form']['questions']).to eq([{ "question_id" => 1, "text" => 'Who is it?' }, { "question_id" => 2, "text" => 'Human?' }, { "question_id" => 3, "text" => 'Hello?' }, { "question_id" => 4, "text" => 'Favorite Power Ranger?' }])
		end

		it 'POST create responds with 422 unprocessable entity if questions not in correct form' do
			post :create, params: { iteration_id: @iteration.id, questions: { questions: ['Who is it?', 'Human?'] } }
			expect(status).to eq(422)

			post :create, params: { iteration_id: @iteration.id, questions: 'Who is it?' }
			expect(status).to eq(422)
			expect(errors['questions'][0]).to include("can't be blank")
		end

		it "POST create responds with 403 forbidden if iteration_id in not from one of lecturer's projects" do
			iteration = FactoryGirl.create(:iteration)
			post :create, params: { iteration_id: iteration.id, questions: ['Who is it?', 'Human?', 'Hello?', 'Favorite Power Ranger?'] }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated')
		end

		# it 'PATCH update responds with 201 if correct params' do
		# 	pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)
		# 	patch :update, params: { id: pa_form.id, questions: ['new Who is it?', 'Human?', 'new Hello?', 'Favorite Power Ranger?'] }
		# 	expect(status).to eq(200)
		# 	expect(body['pa_form']['questions']).to eq([{ "question_id" => 1, "text" => 'new Who is it?' }, { "question_id" => 2, "text" => 'Human?' }, { "question_id" => 3, "text" => 'new Hello?' }, { "question_id" => 4, "text" => 'Favorite Power Ranger?' }])
		# end

		# it 'PATCH update responds with 422 unprocessable entity if questions not in correct form' do
		# 	pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)
		# 	pa_form_wrong = FactoryGirl.create(:pa_form)
		# 	patch :update, params: { id: pa_form_wrong.id, questions: { questions: ['Who is it?', 'Human?'] } }
		# 	expect(status).to eq(403)

		# 	post :create, params: { id: pa_form.id, iteration_id: @iteration.id, questions: 'Who is it?' }
		# 	expect(status).to eq(422)
		# 	expect(errors['questions'][0]).to include("can't be blank")
		# end

		# it 'DELETE destroy responds with 204 no content if lecturer is owner' do
		# 	pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)
		# 	delete :destroy, params: { id: pa_form.id }
		# 	expect(status).to eq(204)
		# end
	end


	describe 'Student' do

		before(:each) do
			@controller = V1::PAFormsController.new
			@student = FactoryGirl.build(:student_with_password).process_new_record
			@student.save
			@student.confirm
			@team = FactoryGirl.create(:team, project_id: @project.id)
			@team.students << @student
			mock_request = MockRequest.new(valid = true, @student)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		it 'GET index returns the active PAForms' do
			now = DateTime.now
			iteration1 = FactoryGirl.create(:iteration, start_date: now + 3.days, deadline: now + 5.days, project_id: @project.id)
			iteration2 = FactoryGirl.create(:iteration, start_date: now + 4.days, deadline: now + 6.days, project_id: @project.id)
			FactoryGirl.create(:pa_form, iteration: iteration1)
			FactoryGirl.create(:pa_form, iteration: iteration2)
			irrelevant = FactoryGirl.create(:pa_form)
			expect(PAForm.all.length).to eq 3

			Timecop.travel(now + 5.days + 1.minute) do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index
				expect(status).to eq 200
				expect(body['pa_forms'].length).to eq(1)
			end

			Timecop.travel(now + 6.days + 1.minute) do
				mock_request = MockRequest.new(valid = true, @student)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index
				expect(status).to eq 204
			end
		end

		it 'GET show returns the PAForm if associated with current user' do
			pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)
			get :show, params: { id: pa_form.id }
			expect(status).to eq(200)
			expect(body['pa_form']['id']).to eq(pa_form.id)
		end

		it 'GET show responds with 403 forbidden if the project is not associated with current user' do
			pa_form = FactoryGirl.create(:pa_form)
			get :show, params: { id: pa_form.id }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated')
		end
	end

end
