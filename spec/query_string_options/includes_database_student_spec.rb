require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe 'Includes', type: :controller do

	context 'Student' do

		before(:all) do
			@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
			@lecturer.save
			@lecturer.confirm
			@unit = FactoryGirl.create(:unit, lecturer: @lecturer)
			@project = FactoryGirl.create(:project_with_teams, unit: @unit, lecturer: @lecturer)
			3.times { @project.teams.first.students << FactoryGirl.build(:student) }
			expect(@project.teams.length).to eq(2)
			expect(@project.teams.first.students.length).to eq(3)

			@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer)
			@project2 = FactoryGirl.create(:project_with_teams, unit: @unit2, lecturer: @lecturer)
			3.times { @project2.teams.first.students << FactoryGirl.build(:student) }
			expect(@project2.teams.length).to eq(2)
			expect(@project2.teams.first.students.length).to eq(3)

			@student = FactoryGirl.build(:student_with_password).process_new_record
			@student.save
			@student.confirm

			@project.teams[0].students << @student
			@project2.teams[0].students << @student
		end

		before(:each) do
			mock_request = MockRequest.new(valid = true, @student)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'Projects' do

			before(:each) do
				@controller = V1::ProjectsController.new
			end

			context 'Valid' do

				it 'makes only one query for teams and unit' do
					expect {
						get :show, params: { id: @project.id }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200) #1

					expect {
						get :show, params: { id: @project.id, includes: 'teams,unit' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200) #2

					expect {
						get :show, params: { id: @project.id, includes: 'teams', compact: true }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)

					expect {
						get :index, params: { includes: 'teams,unit' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)
				end
			end

			context 'Invalid' do
				it 'projects should render errors for invalid includes params' do
					expect {
						get :show, params: { id: @project.id, includes: 'teams,unit,lecturer,banana' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400) #1
					expect(body['errors']['base'].first).to eq("Invalid 'includes' parameter. Project resource for Student user accepts only: lecturer, unit, teams, students. Received: teams,unit,lecturer,banana.")

					expect {
						get :show, params: { id: @project.id, includes: 'teams,unit,lecturer,banana,manyother,wrong_params,$@^&withsymbols,*,**' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400) #1
					expect(body['errors']['base'].first).to eq("Invalid 'includes' parameter. Project resource for Student user accepts only: lecturer, unit, teams, students. Received: teams,unit,lecturer,banana,manyother,wrong_params,$@^&withsymbols,*,**.")

					expect {
						get :show, params: { id: @project.id, includes: '*,**' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400) #1
					expect(body['errors']['base'].first).to eq("Invalid 'includes' parameter. Project resource for Student user accepts only: lecturer, unit, teams, students. Received: *,**.")
				end
			end
		end

		describe 'Units' do
			before(:each) do
				@controller = V1::UnitsController.new
			end

			context 'Valid' do
				it 'makes only one query for project, department and students' do
					unit = @lecturer.units[0]
					expect {
						get :show, params: { id: unit.id, includes: 'department,lecturer' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)
				end
			end

			context 'Invalid' do
				it 'units responds with 400 for unsupported associations in includes' do
					expect {
						get :index, params: { includes: 'students,project' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400)
					expect(body['errors']['base'][0]).to include("Invalid 'includes' parameter. Unit resource for Student user accepts only: lecturer, department. Received: students,project.")

					unit = @lecturer.units[0]
					expect {
						get :show, params: { id: unit.id, includes: 'students,project' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400)
					expect(body['errors']['base'][0]).to eq("Invalid 'includes' parameter. Unit resource for Student user accepts only: lecturer, department. Received: students,project.")
				end
			end
		end

		describe 'Teams' do
			before(:each) do
				@controller = V1::TeamsController.new
			end

			context 'Valid' do
				it 'index_with_project makes two query for project and students (+1 for only_if lecturer)' do
					project = @lecturer.projects[0]
					expect {
						get :index, params: { includes: 'project' }
					}.to make_database_queries(count: 2)
					expect(status).to eq(200)
				end

				it 'show makes one query for project and students (+1 for only_if lecturer)' do
					team = @student.teams[0]
					expect {
						get :show, params: { id: team.id, includes: 'project,students' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)
				end
			end

			context 'Invalid' do
				it 'teams responds with 400 for unsupported associations in includes' do
					expect {
						get :index, params: { includes: 'department,projects,students' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(400)
					expect(body['errors']['base'][0]).to eq("Invalid 'includes' parameter. Team resource for Student user accepts only: project, students, lecturer. Received: department,projects,students.")

					team = @lecturer.teams[0]
					expect {
						get :show, params: { id: team.id, includes: 'department,projects,students' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400)
					expect(body['errors']['base'][0]).to eq("Invalid 'includes' parameter. Team resource for Student user accepts only: project, students, lecturer. Received: department,projects,students.")
				end
			end
		end
	end
end
