require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe 'Includes', type: :controller do

	context 'Lecturer' do

		before(:all) do
			@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
			@lecturer.save
			@lecturer.confirm
			@unit = FactoryGirl.create(:unit, lecturer: @lecturer)
			@assignment = FactoryGirl.create(:assignment_with_projects, unit: @unit, lecturer: @lecturer)
			3.times { create :students_project, student: create(:student), project: @assignment.projects[0] }#@assignment.projects.first.students << FactoryGirl.build(:student) }
			expect(@assignment.projects.length).to eq(2)
			expect(@assignment.projects.first.students.length).to eq(3)
		end

		before(:each) do
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'Assignments' do

			before(:each) do
				@controller = V1::AssignmentsController.new
			end

			context 'Valid' do

				it 'makes only on query for projects and unit' do
					expect {
						get :show, params: { id: @assignment.id }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200) #1

					expect {
						get :show, params: { id: @assignment.id, includes: 'projects,unit' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200) #2

					expect {
						get :show, params: { id: @assignment.id, includes: 'projects', compact: true }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)

					expect {
						get :index, params: { includes: 'projects,unit' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)
				end
			end

			context 'Invalid' do
				it 'should render errors for invalid includes params' do
					expect {
						get :show, params: { id: @assignment.id, includes: 'projects,unit,lecturer,banana' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400) #1
					expect(body['errors']['base'].first).to include("Invalid 'includes' parameter")

					expect {
						get :show, params: { id: @assignment.id, includes: 'projects,unit,lecturer,banana,manyother,wrong_params,$@^&withsymbols,*,**' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400) #1
					expect(body['errors']['base'].first).to include("Invalid 'includes' parameter")

					expect {
						get :show, params: { id: @assignment.id, includes: '*,**' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400) #1
					expect(body['errors']['base'].first).to include("Invalid 'includes' parameter")
				end
			end
		end

		describe 'Units' do
			before(:each) do
				@controller = V1::UnitsController.new
			end

			context 'Valid' do
				it 'makes only one query for project, department and students (+1 for only_if lecturer)' do
					expect {
						get :index, params: { includes: 'department,assignments,lecturer' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)

					unit = @lecturer.units[0]
					expect {
						get :show, params: { id: unit.id, includes: 'department,assignments,lecturer' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)
				end
			end

			context 'Invalid' do
				it 'responds with 400 for unsupported associations in includes' do
					expect {
						get :index, params: { includes: 'students,project' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400)
					expect(body['errors']['base'][0]).to eq("Invalid 'includes' parameter. Unit resource for Lecturer user accepts only: lecturer, assignments, department. Received: students,project.")

					unit = @lecturer.units[0]
					expect {
						get :show, params: { id: unit.id, includes: 'students,project' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400)
					expect(body['errors']['base'][0]).to eq("Invalid 'includes' parameter. Unit resource for Lecturer user accepts only: lecturer, assignments, department. Received: students,project.")
				end
			end
		end

		describe 'Projects' do
			before(:each) do
				@controller = V1::ProjectsController.new
			end

			context 'Valid' do
				it 'index_with_assignment makes two query for project and students (+1 for only_if lecturer)' do
					expect {
						get :index_with_assignment, params: { includes: 'assignment', assignment_id: @lecturer.assignments[0].id }
					}.to make_database_queries(count: 2)
					expect(status).to eq(200)
				end

				it 'show makes one query for project and students (+1 for only_if lecturer)' do
					project = @lecturer.projects[0]
					expect {
						get :show, params: { id: project.id, includes: 'assignment,students' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)
				end

				it 'index makes one query for includes unit and assignment compact' do
					expect {
						get :index, params: { includes: 'unit,assignment', compact: true }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)
				end
			end

			context 'Invalid' do
				it 'projects responds with 400 for unsupported associations in includes' do
					expect {
						get :index_with_assignment, params: { includes: 'department,projects,students' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400)
					expect(body['errors']['base'][0]).to include("Received: department,projects,students.")

					project = @lecturer.projects[0]
					expect {
						get :show, params: { id: project.id, includes: 'department,projects,students' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400)
					expect(body['errors']['base'][0]).to include("Received: department,projects,students.")
				end
			end
		end
	end
end
