require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe 'Includes', type: :controller do

	context 'Student' do

		before(:all) do
			@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
			@lecturer.save
			@lecturer.confirm
			@unit = FactoryGirl.create(:unit, lecturer: @lecturer)
			@assignment = FactoryGirl.create(:assignment_with_projects, unit: @unit, lecturer: @lecturer)
			3.times { create :students_project, student: create(:student), project: @assignment.projects[0] }
			expect(@assignment.projects.length).to eq(2)
			expect(@assignment.projects.first.students.length).to eq(3)

			@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer)
			@assignment2 = FactoryGirl.create(:assignment_with_projects, unit: @unit2, lecturer: @lecturer)
			3.times { create :students_project, student: create(:student), project: @assignment2.projects[0] }
			expect(@assignment2.projects.length).to eq(2)
			expect(@assignment2.projects.first.students.length).to eq(3)

			@student = FactoryGirl.build(:student_with_password).process_new_record
			@student.save
			@student.confirm

			#@assignment.projects[0].students << @student
			#@assignment2.projects[0].students << @student
			create :students_project, student: @student, project: @assignment.projects[0]
			create :students_project, student: @student, project: @assignment2.projects[0]
		end

		before(:each) do
			mock_request = MockRequest.new(valid = true, @student)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'Assignments' do

			before(:each) do
				@controller = V1::AssignmentsController.new
			end

			context 'Valid' do

				it 'makes only one query for iterations and unit' do
					expect {
						get :show, params: { id: @assignment.id }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200) #1

					expect {
						get :show, params: { id: @assignment.id, includes: 'iterations,unit' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200) #2

					expect {
						get :show, params: { id: @assignment.id, includes: 'iterations', compact: true }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)
				end
			end

			context 'Invalid' do
				it 'projects should render errors for invalid includes params' do
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

		describe 'Projects' do
			before(:each) do
				@controller = V1::ProjectsController.new
			end

			context 'Valid' do
				it 'index_with_project makes two query for assignment and students (+1 for only_if lecturer)' do
					expect {
						get :index, params: { includes: 'assignment' }
					}.to make_database_queries(count: 3)
					expect(status).to eq(200)
				end

				it 'show makes one query for project and students (+1 for only_if lecturer)' do
					project = @student.projects[0]
					expect {
						get :show, params: { id: project.id, includes: 'assignment,students' }
					}.to make_database_queries(count: 7)
					expect(status).to eq(200)
				end
			end

			context 'Invalid' do
				it 'projects responds with 400 for unsupported associations in includes' do
					expect {
						get :index, params: { includes: 'department,assignments,students' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400)
					expect(body['errors']['base'][0]).to eq("Invalid 'includes' parameter. Project resource for Student user accepts only: assignment, students, lecturer. Received: department,assignments,students.")

					project = @lecturer.projects[0]
					expect {
						get :show, params: { id: project.id, includes: 'department,assignments,students' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400)
					expect(body['errors']['base'][0]).to eq("Invalid 'includes' parameter. Project resource for Student user accepts only: assignment, students, lecturer. Received: department,assignments,students.")
				end
			end
		end
	end
end
