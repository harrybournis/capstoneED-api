require 'rails_helper'

RSpec.describe V1::IterationsController, type: :controller do

		before(:all) do
			@controller = V1::IterationsController.new
			@user = FactoryGirl.create(:lecturer)

			@unit = FactoryGirl.create(:unit, lecturer_id: @user.id)
			2.times { FactoryGirl.create(:assignment_with_projects, unit_id: @unit.id, lecturer_id: @user.id)}
			@irrelevant_assignment = FactoryGirl.create(:assignment_with_projects)

			FactoryGirl.create(:iteration, assignment_id: @user.assignments[0].id)
			2.times { FactoryGirl.create(:iteration, assignment_id: @user.assignments[1].id) }
			expect(@user.assignments[0].iterations.count).to eq(1)
			expect(@user.assignments[1].iterations.count).to eq(2)
		end

		before(:each) do
			@controller = V1::IterationsController.new
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

	context 'Valid' do



		it 'GET index needs a assignment_id and it must be associated with current_user', { docs?: true } do
			assignment = @user.assignments[1]
			get :index, params: { assignment_id: assignment.id }
			expect(status).to eq(200)
			expect(body['iterations'].length).to eq(2)
		end

		it 'GET index works for students' do
			@user = FactoryGirl.create(:student)
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			Assignment.first.projects << FactoryGirl.create(:project)
			create :students_project, student: @user, project: Assignment.first.projects.first

			get :index, params: { assignment_id: Assignment.first.id }
			expect(status).to eq(200)
			expect(body['iterations'].length).to eq(Assignment.first.iterations.length)
		end

		it 'GET index returns 204 if no iterations for the assignment_id' do
			assignment = create :assignment, lecturer: @user
			expect(assignment.iterations.count).to eq 0
			expect(assignment.lecturer).to eq @user

			get :index, params: { assignment_id: assignment.id }

			expect(status).to eq 204
		end

		it 'GET index returns 204 if assignment id does not belong to current user' do
			assignment = create :assignment
			expect(assignment.iterations.count).to eq 0
			expect(assignment.lecturer).to_not eq @user

			get :index, params: { assignment_id: assignment.id }

			expect(status).to eq 204
		end

		it 'GET show iteration needs the assignment to be associated with current_user', { docs?: true } do
			get :show, params: { id: @user.assignments[1].iterations[0].id }
			expect(status).to eq(200)
			expect(body['iteration']['name']).to eq(@user.assignments[1].iterations[0].name)
		end

		it 'GET show iteration needs the assignment to be associated with current_user' do
			@user = FactoryGirl.create(:student)
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			Assignment.first.projects << FactoryGirl.create(:project)
			create :students_project, student: @user, project: Assignment.first.projects.first

			get :show, params: { id: Assignment.first.iterations[0].id }
			expect(status).to eq(200)
			expect(body['iteration']['name']).to eq(Assignment.first.iterations[0].name)
		end

		it 'POST create current user must be associated with the assignment', { docs?: true } do
			post :create, params: { assignment_id: @user.assignments[0].id, name: 'name', start_date: DateTime.now + 1.week, deadline: DateTime.now + 3.months }
			expect(status).to eq(201)
			expect(body['iteration']['name']).to eq('name')
		end

		it 'POST create accepts params for pa_form', { docs?: true } do
			attributes = attributes_for(:pa_form)
			questions = attributes[:questions]
			post :create, params: { assignment_id: @user.assignments[0].id, name: 'name', start_date: DateTime.now + 1.week, deadline: DateTime.now + 3.months, pa_form_attributes: attributes }
			expect(status).to eq(201)
			expect(body['iteration']['pa_form']['questions']).to eq(PaForm.find(body['iteration']['pa_form']['id']).questions)
		end

		it 'PATCH update current user must be associated with the project', { docs?: true } do
			patch :update, params: { id: @user.assignments[1].iterations[0], name: 'different' }
			expect(status).to eq(200)
			expect(body['iteration']['name']).to eq('different')
		end

		it 'DELETE destroy current user must be associated with the project' do
			delete :destroy, params: { id: @user.assignments[1].iterations[0] }
			expect(status).to eq(204)
		end

		it 'GET index return with the extensions on the pa_forms' do
			now = DateTime.now
			@assignment = FactoryGirl.create(:assignment, lecturer: @user, unit: @unit)
			@iteration = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
			@iteration1 = FactoryGirl.create(:iteration, start_date: now + 3.days, deadline: now + 5.days, assignment_id: @assignment.id)
			@iteration2 = FactoryGirl.create(:iteration, start_date: now + 4.days, deadline: now + 6.days, assignment_id: @assignment.id)
			@iteration3 = FactoryGirl.create(:iteration, start_date: now + 4.days, deadline: now + 6.days + 1.hour, assignment_id: @assignment.id)
			pa_form0 = FactoryGirl.create(:pa_form, iteration: @iteration)
			pa_form1 = FactoryGirl.create(:pa_form, iteration: @iteration1)
			pa_form2 = FactoryGirl.create(:pa_form, iteration: @iteration2)
			pa_form3 = FactoryGirl.create(:pa_form, iteration: @iteration3)
			@student = FactoryGirl.build(:student_with_password).process_new_record
			@student.save
			@student.confirm
			@project = FactoryGirl.create(:project, assignment_id: @assignment.id)
			create :students_project, student: @student, project: @project
			extension = FactoryGirl.create(:extension, project_id: @project.id, deliverable_id: pa_form1.id)
			extension2 = FactoryGirl.create(:extension, project_id: @project.id, deliverable_id: pa_form2.id)

			Timecop.travel(now + 5.days + 1.minute) do
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
				get :index, params: { assignment_id: @assignment.id }
				expect(status).to eq 200
				expect(body['iterations'].length).to eq(4)
				body['iterations'].each do |i|
					if i['id'] == @iteration1.id
						expect(i['pa_form']['extensions'].length).to eq @iteration1.pa_form.extensions.length
					end
				end
			end
		end
	end


	context 'Invalid' do

		it 'GET index should respond with 400 forbidden if assignment_id is missing' do
			assignment = @user.assignments[1]
			get :index
			expect(status).to eq(400)
			expect(errors['base'][0]).to include('This Endpoint requires a assignment_id in the params')
		end

		it 'GET show responds with 403 forbidden if user is not associated with iteration assignment' do
			assignment = FactoryGirl.create(:assignment)
			get :show, params: { id: assignment.id }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated with the current user')
		end

		it 'POST create responds with 403 if assignment_id is not associated with current_user' do
			irrelevant_assignment = create :assignment

			post :create, params: { assignment_id: irrelevant_assignment.id, name: 'name', start_date: DateTime.now + 1.week, deadline: DateTime.now + 3.months }

			expect(status).to eq(403)
			expect(errors['assignment_id'][0]).to eq("is not one of current user's assignments")
		end

		it 'PATCH update responds with 403 if id is not associated with current_user' do
			iteration = FactoryGirl.create(:iteration)
			patch :update, params: { id: iteration.id, name: 'different' }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated with the current user')
		end

		it 'DELETE destroy responds with 403 if id is not associated with current_user' do
			iteration = FactoryGirl.create(:iteration)
			patch :update, params: { id: iteration.id, name: 'different' }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated with the current user')
		end

	end
end
