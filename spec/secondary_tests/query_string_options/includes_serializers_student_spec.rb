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
			3.times { @assignment.projects.first.students << FactoryGirl.build(:student) }
			expect(@assignment.projects.length).to eq(2)
			expect(@assignment.projects.first.students.length).to eq(3)

			@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer)
			@assignment2 = FactoryGirl.create(:assignment_with_projects, unit: @unit2, lecturer: @lecturer)
			3.times { @assignment2.projects.first.students << FactoryGirl.build(:student) }
			expect(@assignment2.projects.length).to eq(2)
			expect(@assignment2.projects.first.students.length).to eq(3)

			@student = FactoryGirl.build(:student_with_password).process_new_record
			@student.save
			@student.confirm

			@assignment.projects[0].students << @student
			@assignment2.projects[0].students << @student
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

			it 'GET index can include lecturer' do
				get :index, params: { includes: 'students,assignment,lecturer', compact: true }
				expect(status).to eq(200)
				expect(body['projects'].first['students'].first).to_not include('email', 'provider')
				expect(body['projects'].length).to eq(2)
				expect(body['projects'].first['assignment']).to_not include('description')
				expect(body['projects'].first['lecturer']).to include('id')
			end

			it 'GET without students' do
				get :index, params: { includes: 'assignment' }
				#binding.pry
			end
		end

		describe 'Unit' do
			before(:each) do
				@controller = V1::UnitsController.new
			end

			it 'GET index can not include projects' do
				get :show, params: { id: @unit.id, includes: 'projects'}
				expect(response.status).to eq(400)
				expect(body['errors']['base'].first).to include("Invalid 'includes' parameter. Unit resource for Student user accepts only: lecturer, department. Received: projects.")
			end
		end

		describe 'Iteration' do
			before(:each) do
				@controller = V1::IterationsController.new
			end

			it 'GET index includes pa_form' do
				iteration = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
				iteration2 = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
				pa_form = FactoryGirl.create(:pa_form, iteration: iteration)
				pa_form2 = FactoryGirl.create(:pa_form, iteration: iteration2)

				get :index, params: { assignment_id: @assignment.id }
				expect(status).to eq(200)
				expect(body['iterations'].length).to eq(2)
				expect(body['iterations'][1]['pa_form']['questions']).to eq(pa_form2.questions)
			end

			it 'GET show includes pa_form' do
				iteration = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
				pa_form = FactoryGirl.create(:pa_form, iteration: iteration)

				get :show, params: { id: iteration.id }
				expect(status).to eq(200)
				expect(body['iteration']['pa_form']['questions']).to eq(pa_form.questions)
			end
		end
	end
end
