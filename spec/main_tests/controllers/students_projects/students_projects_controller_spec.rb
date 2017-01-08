require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::StudentsProjectsController, type: :controller do


	before(:all) do
		@lecturer = get_lecturer_with_units_assignments_projects
		@student = FactoryGirl.create(:student_with_password).process_new_record
		@student.save
		@student.confirm
		#@lecturer.projects.first.students << @student
		#@lecturer.projects.last.students 	<< @student
		create :students_project, student: @student, project: @lecturer.projects.first
		create :students_project, student: @student, project: @lecturer.projects.last
	end

	context 'Student' do

		before(:each) do
			@controller = V1::StudentsProjectsController.new
			mock_request = MockRequest.new(valid = true, @student)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'POST enrol' do

			it 'creates a new StudentsProject instance with nickname', { docs?: true, lecturer?: false, controller_class: "V1::ProjectsController" } do
				project = FactoryGirl.create(:project)
				nickname = "giorgakis"
				expect {
					post :enrol, params: { enrollment_key: project.enrollment_key, id: project.id, nickname: nickname }
				}.to change { JoinTables::StudentsProject.all.count }.by(1)
				expect(status).to eq(201)
				expect(body['project']['nickname']).to be_truthy
				@student.reload
				expect(@student.projects.include? project).to be_truthy
				expect(@student.nickname_for_project_id(project.id)).to eq(body['project']['nickname'])
			end

			it 'responds with 403 unprocessable_entity if no nickname', { docs?: true, lecturer?: false, controller_class: "V1::ProjectsController" } do
				project = FactoryGirl.create(:project)
				nickname = "giorgakis"
				expect {
					post :enrol, params: { enrollment_key: project.enrollment_key, id: project.id }
				}.to change { JoinTables::StudentsProject.all.count }.by(0)
				expect(status).to eq(403)
				expect(errors['nickname'][0]).to include 'blank'
			end

			it 'responds with 422 unprocessable_entity if id does not exist' do
				project = FactoryGirl.create(:project)
				expect {
					post :enrol, params: { enrollment_key: project.enrollment_key, id: 474774373, nickname: 'batman' }
				}.to_not change { JoinTables::StudentsProject.all.count }
				expect(status).to eq(422)
				expect(errors['id'].first).to include('exist')
			end

			it 'responds with 403 unprocessable_entity if wrong enrollment key', { docs?: true, lecturer?: false, controller_class: "V1::ProjectsController" } do
				project = FactoryGirl.create(:project)
				expect {
					post :enrol, params: { enrollment_key: 'invalidkey', id: project.id, nickname: 'batman' }
				}.to_not change { JoinTables::StudentsProject.all.count }
				expect(status).to eq(403)
				expect(errors['enrollment_key'].first).to eq('is invalid')
			end

			it 'responds with 403 forbidden if they try to enrol on the same project twice' do
				expect {
					post :enrol, params: { enrollment_key: @student.projects[0].enrollment_key, id: @student.projects[0].id, nickname: 'batman' }
				}.to_not change { JoinTables::StudentsProject.all.count }
				expect(status).to eq(403)
				expect(errors['student_id'].first).to eq('can not exist in the same Project twice')
			end

			it 'responds with 403 forbidden if they try to enrol on two projects for the same assignment' do
				project = FactoryGirl.create(:project)
				@student.assignments[0].projects << project
				expect(@student.projects.include? project).to be_falsy
				expect {
					post :enrol, params: { enrollment_key: project.enrollment_key, id: project.id, nickname: 'batman' }
				}.to_not change { JoinTables::StudentsProject.all.count }
				expect(status).to eq(403)
				expect(errors['student_id'].first).to include('already enroled')
			end
		end

		describe 'PATCH update_nickname' do

			it 'responds with 200 and the new nickname if successfull', { docs?: true, lecturer?: false, controller_class: "V1::ProjectsController" } do
				nickname = 'giorgakis'
				patch :update_nickname, params: { id: @student.projects[0].id, nickname: nickname }
				expect(status).to eq(200)
				expect(body['nickname']).to eq(nickname)
				expect(JoinTables::StudentsProject.where(project_id: @student.projects[0].id, student_id: @student.id)[0].nickname).to eq(nickname)
			end

			it 'responds with 403 forbidden if student not enrolled in project' do
				project = FactoryGirl.create(:project)
				#project.students << FactoryGirl.create(:student)
				create :students_project, student: create(:student), project: project

				patch :update_nickname, params: { id: project.id, nickname: 'nicname' }

				expect(status).to eq(403)
				expect(errors['base'][0]).to include('not associated')
			end

			it 'responds with 422 unprocessable_entity if nickname is not in the params' do
				patch :update_nickname, params: { id: @student.projects[0].id }
				expect(status).to eq(422)
				expect(errors['nickname'][0]).to include("was not provided")
			end
		end

		describe 'POST /logs' do
			it 'responds with 200 if valid', { docs?: true, lecturer?: false, controller_class: "V1::ProjectsController" } do
				post :update_logs, params: FactoryGirl.build(:students_project).logs[0].except(:date_submitted).merge(id: @student.projects[0].id)
				expect(status).to eq(200)
				expect(body['log_entry']).to be_truthy
			end

			it 'responds with 422 if invalid log parameters', { docs?: true, lecturer?: false, controller_class: "V1::ProjectsController" } do
				post :update_logs, params: FactoryGirl.build(:students_project).logs[0].except("date_submitted", "time_worked").merge(id: @student.projects[0].id)
				expect(status).to eq(422)
				expect(errors['log_entry'][0]).to include('is missing')
			end

			it 'responds with 403 if not enrolled in project' do
				project = FactoryGirl.create(:project)
				post :update_logs, params: FactoryGirl.attributes_for(:students_project).merge(id: project.id)
				expect(status).to eq(403)
			end
		end

		describe 'GET /logs' do
			it 'responds with 200 and the students logs', { docs?: true, lecturer?: false, controller_class: "V1::ProjectsController" } do
				project = @student.projects[0]
				sp = JoinTables::StudentsProject.where(project_id: project.id, student_id: @student.id)[0]
				sp.logs = []
				expect(sp.save).to be_truthy
				sp.add_log(FactoryGirl.build(:students_project).logs[0])
				expect(sp.save).to be_truthy
				sp.add_log(FactoryGirl.build(:students_project).logs[0])
				expect(sp.save).to be_truthy

				get :index_logs_student, params: { id: project.id }

				expect(status).to eq(200)
				expect(body["logs"].length).to eq(2)
			end

			it 'responds with 403 if the student does not belong to project' do
				project = FactoryGirl.create(:project)
				get :index_logs_student, params: {  id: project.id }
				expect(status).to eq(403)
			end
		end
	end

	context 'Lecturer' do

		before(:each) do
			@controller = V1::StudentsProjectsController.new
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'POST enrol' do
			it 'responds with 403 forbidden if lecturer' do
				@controller = V1::StudentsProjectsController.new
				expect {
					post :enrol, params: { enrollment_key: 'something' }
				}.to_not change { JoinTables::StudentsProject.all.size }
				expect(status).to eq(403)
			end
		end

		describe 'POST update_nickname' do
			it 'responds with 403 forbidden if lecturer' do
				patch :update_nickname, params: { id: @lecturer.projects[0].id, nickname: 'giorgakis' }
				expect(status).to eq(403)
			end
		end

		describe 'DELETE remove_student' do

			before :each do
				@controller = V1::StudentsProjectsController.new
			end

			it 'removes student from project if Lecturer is owner', { docs?: true, controller_class: "V1::ProjectsController" } do
				@lecturer.reload
				student = FactoryGirl.create(:student)
				#@lecturer.projects[0].students << student
				create :students_project, student: student, project: @lecturer.projects[0]

				expect {
					delete :remove_student, params: { id: @lecturer.projects[0].id, student_id: student.id }
				}.to change { @lecturer.projects[0].students.count }.by(-1)

				expect(status).to eq(204)
			end

			it 'responds with 400 if no student_id present in params' do
				delete :remove_student, params: { id: @lecturer.projects[0].id }
				expect(status).to eq(400)
				expect(errors['student_id'][0]).to eq("can't be blank")
			end

			it 'responds with 422 if student_id does not belong in project' do
				project = FactoryGirl.create(:project)
				other_student = FactoryGirl.create(:student)
				#project.students << other_student
				create :students_project, student: other_student, project: project
				delete :remove_student, params: { id: @lecturer.projects[0].id, student_id: other_student.id }
				expect(status).to eq(422)
				expect(errors['base'][0]).to include("Can't find Student")
				@lecturer.reload
				expect(@lecturer.projects.first.students.length).to eq(1)
			end
		end

		describe 'GET /logs' do
			it 'responds with 200 and the students logs', { docs?: true, controller_class: "V1::ProjectsController" } do
				project = @student.projects[0]
				sp = JoinTables::StudentsProject.where(project_id: project.id, student_id: @student.id)[0]
				sp.logs = []
				expect(sp.save).to be_truthy
				sp.add_log(FactoryGirl.build(:students_project).logs[0])
				expect(sp.save).to be_truthy
				sp.add_log(FactoryGirl.build(:students_project).logs[0])
				expect(sp.save).to be_truthy

				get :index_logs_lecturer, params: { id: project.id, student_id: @student.id }

				expect(status).to eq(200)
				expect(body["logs"].length).to eq(2)
			end

			it 'responds with 422 if the student does not belong to project' do
				project = @lecturer.projects.second
				get :index_logs_lecturer, params: {  id: project.id, student_id: @student.id }
				expect(status).to eq(422)
				expect(errors["student_id"][0]).to include("does not belong to this project")
			end

			it 'responds with 403 if the project does not belong to the lecturer' do
				project = FactoryGirl.create(:project)
				get :index_logs_lecturer, params: {  id: project.id, student_id: @student.id }
				expect(status).to eq(403)
			end
		end
	end
end
