require 'rails_helper'

RSpec.describe V1::IterationsController, type: :controller do

		before(:all) do
			@controller = V1::IterationsController.new
			@user = FactoryGirl.create(:lecturer)
			# mock_request = MockRequest.new(valid = true, @user)
			# request.cookies['access-token'] = mock_request.cookies['access-token']
			# request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			@unit = FactoryGirl.create(:unit, lecturer_id: @user.id)
			2.times { FactoryGirl.create(:project_with_teams, unit_id: @unit.id, lecturer_id: @user.id)}
			@irrelevant_project = FactoryGirl.create(:project_with_teams)

			FactoryGirl.create(:iteration, project_id: @user.projects[0].id)
			2.times { FactoryGirl.create(:iteration, project_id: @user.projects[1].id) }
			expect(@user.projects[0].iterations.count).to eq(1)
			expect(@user.projects[1].iterations.count).to eq(2)
		end

		before(:each) do
			@controller = V1::IterationsController.new
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

	context 'Valid' do



		it 'GET index needs a project_id and it must be associated with current_user' do
			project = @user.projects[1]
			get :index, params: { project_id: project.id }
			expect(status).to eq(200)
			expect(body['iterations'].length).to eq(2)
		end

		it 'GET index works for students' do
			@user = FactoryGirl.create(:student)
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			Project.third.teams << FactoryGirl.create(:team)
			Project.third.teams.first.students << @user

			get :index, params: { project_id: Project.third.id }
			expect(status).to eq(200)
			expect(body['iterations'].length).to eq(Project.third.iterations.length)
		end

		it 'GET show iteration needs the project to be associated with current_user' do
			get :show, params: { id: @user.projects[1].iterations[0].id }
			expect(status).to eq(200)
			expect(body['iteration']['name']).to eq(@user.projects[1].iterations[0].name)
		end

		it 'GET show iteration needs the project to be associated with current_user' do
			@user = FactoryGirl.create(:student)
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			Project.third.teams << FactoryGirl.create(:team)
			Project.third.teams.first.students << @user

			get :show, params: { id: Project.third.iterations[0].id }
			expect(status).to eq(200)
			expect(body['iteration']['name']).to eq(Project.third.iterations[0].name)
		end

		it 'POST create current user must be associated with the project' do
			post :create, params: { project_id: @user.projects[0].id, name: 'name', start_date: DateTime.now + 1.week, deadline: DateTime.now + 3.months }
			expect(status).to eq(201)
			expect(body['iteration']['name']).to eq('name')
		end

		it 'POST create accepts params for pa_form' do
			post :create, params: { project_id: @user.projects[0].id, name: 'name', start_date: DateTime.now + 1.week, deadline: DateTime.now + 3.months, pa_form_attributes: { questions: ['Who is it?', 'Human?', 'Hello?', 'Favorite Power Ranger?'], start_offset: 0, end_offset: 5.days.to_i } }
			expect(status).to eq(201)
			expect(body['iteration']['pa_form']['questions']).to eq([{"question_id"=>1, "text"=>"Who is it?"}, {"question_id"=>2, "text"=>"Human?"}, {"question_id"=>3, "text"=>"Hello?"}, {"question_id"=>4, "text"=>"Favorite Power Ranger?"}])
		end

		it 'PATCH update current user must be associated with the project' do
			patch :update, params: { id: @user.projects[1].iterations[0], name: 'different' }
			expect(status).to eq(200)
			expect(body['iteration']['name']).to eq('different')
		end

		it 'DELETE destroy current user must be associated with the project' do
			delete :destroy, params: { id: @user.projects[1].iterations[0] }
			expect(status).to eq(204)
		end
	end


	context 'Invalid' do

		it 'GET index should respond with 404 not found if project_id is missing' do
			project = @user.projects[1]
			get :index
			expect(status).to eq(400)
			expect(errors['base'][0]).to include('This Endpoint requires a project_id in the params')
		end

		it 'GET index should respond with 403 forbidden is project_id is not one of current users projects' do
			get :index, params: { project_id: @irrelevant_project.id }
			expect(status).to eq(403)
			expect(errors['project_id'][0]).to include("is not one of current user's projects")
		end

		it 'GET show responds with 403 forbidden if user is not associated with iteration project' do
			project = FactoryGirl.create(:project)
			get :show, params: { id: project.id }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated with the current user')
		end

		it 'POST create responds with 403 if project_id is not associated with current_user' do
			post :create, params: { project_id: Project.first.id, name: 'name', start_date: DateTime.now + 1.week, deadline: DateTime.now + 3.months }
			expect(status).to eq(403)
			expect(errors['project_id'][0]).to eq("is not one of current user's projects")
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
