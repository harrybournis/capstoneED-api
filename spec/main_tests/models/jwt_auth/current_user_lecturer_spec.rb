require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe JWTAuth::CurrentUserLecturer, type: :model do

	describe 'Assignments' do

		before(:each) do
			@user = FactoryGirl.create(:lecturer)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

			@unit = FactoryGirl.create(:unit, lecturer: @user)
			@assignment = FactoryGirl.create(:assignment_with_projects, unit: @unit, lecturer: @user)
			3.times { @assignment.projects.first.students << FactoryGirl.build(:student) }
		end

		it 'loads the correct assignments' do
			expect {
				(@assignments = @current_user.assignments).length
			}.to make_database_queries(count: 1)
			expect(@assignments.length).to eq(@current_user.load.assignments.length)
		end

		it 'includes associations' do
			expect {
				@assignments.length if @assignments = @current_user.assignments(includes: 'unit')
			}.to make_database_queries(count: 1)
			expect {
				@assignments[0].unit
			}.to_not make_database_queries

			expect {
				(@assignments = @current_user.assignments(includes: ['unit','projects'])).length
			}.to make_database_queries(count: 1)
			expect {
				@assignments[0].projects
			}.to_not make_database_queries
			expect {
				@assignments[0].unit
			}.to_not make_database_queries

			expect {
				(@assignments = @current_user.assignments(includes: ['lecturer','projects','students'])).length
			}.to make_database_queries(count: 1)
			expect {
				@assignments[0].lecturer
			}.to_not make_database_queries
			expect {
				@assignments[0].projects[0].students
			}.to_not make_database_queries
		end

		it 'can chain queries' do
			expect {
				@assignment_find[0].unit if (@assignment_find = @current_user.assignments(includes: 'unit').where(unit_id: @unit)).length > 0
			}.to make_database_queries(count: 1)
			expect(@assignment_find[0].unit).to eq(@unit)
		end
	end

	describe 'Units' do
		before(:each) do
			@user = FactoryGirl.create(:lecturer)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

			@other_unit = FactoryGirl.create(:unit)
			@unit = FactoryGirl.create(:unit, lecturer: @user)
			@assignment = FactoryGirl.create(:assignment_with_projects, unit: @user.units[0], lecturer: @user)
			3.times { @assignment.projects.first.students << FactoryGirl.build(:student) }
		end

		it 'loads the correct units' do
			@units = @current_user.units
			res = true
			@units.each { |u| res = false unless @user.units.include? u }
			expect(res).to be_truthy
		end

		it 'returns the units with includes without additional database queries' do
			expect {
				(@units = @current_user.units(includes: ['lecturer','department'])).length
			}.to make_database_queries(count: 1)
			expect {
				@units[0].lecturer
			}.to_not make_database_queries
			expect {
				@units[0].department
			}.to_not make_database_queries

			expect {
				(@units = @current_user.units(includes: 'assignments')).length
			}.to make_database_queries(count: 1)
			expect {
				@units[0].assignments[0].start_date
			}.to_not make_database_queries
		end
	end

	describe 'Questions' do
		before(:each) do
			@user = FactoryGirl.create(:lecturer)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

			5.times { @user.questions << FactoryGirl.build(:question) }
			expect(@user.questions.count).to eq(5)
		end

		it 'should make one database query' do
			expect {
				(@questions = @current_user.questions).length
			}.to make_database_queries(count: 1)
			expect(@questions.length).to eq(5)
		end
	end

	describe 'Departments' do
		it 'returns correct number of departments' do
			@user = FactoryGirl.create(:lecturer)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

			2.times { FactoryGirl.create(:unit, lecturer_id: @user.id) }

			expect(@current_user.departments.length).to eq(2)
		end
	end

	describe 'PAForms' do
		it 'returns correct pa_forms' do
			@user = FactoryGirl.create(:lecturer)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

			@unit = FactoryGirl.create(:unit, lecturer: @user)
			@assignment = FactoryGirl.create(:assignment_with_projects, unit: @unit, lecturer: @user)

			iteration = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
			iteration2 = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
			pa_form = FactoryGirl.create(:pa_form, iteration: iteration)
			pa_form2 = FactoryGirl.create(:pa_form, iteration: iteration2)
			expect(@current_user.pa_forms.length).to eq(2)
		end
	end

	describe "Peer Assessment" do
		it 'returns the associated peer assessments' do
			@user = FactoryGirl.create(:lecturer_confirmed)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

			unit = FactoryGirl.create(:unit, lecturer_id: @user.id)
			assignment = FactoryGirl.create(:assignment, lecturer_id: @user.id, unit: unit)
			iteration  = FactoryGirl.create(:iteration, assignment: assignment)
			pa_form = FactoryGirl.create(:pa_form, iteration: iteration)
			project = FactoryGirl.create(:project, assignment: assignment)
			student = FactoryGirl.create(:student_confirmed)
			student2 = FactoryGirl.create(:student_confirmed)
			student3 = FactoryGirl.create(:student_confirmed)
			project.students << student
			project.students << student2
			project.students << student3
			peer_assessment = FactoryGirl.create(:peer_assessment, pa_form: pa_form, submitted_by: student, submitted_for: student2)
			peer_assessment = FactoryGirl.create(:peer_assessment, pa_form: pa_form, submitted_by: student, submitted_for: student3)
			peer_assessment = FactoryGirl.create(:peer_assessment, pa_form: pa_form, submitted_by: student2, submitted_for: student)
			peer_assessment = FactoryGirl.create(:peer_assessment, pa_form: pa_form, submitted_by: student2, submitted_for: student3)
			peer_assessment_irrellevant = FactoryGirl.create(:peer_assessment)

			expect(@current_user.peer_assessments.length).to eq(4)
		end
	end

	describe 'Extension' do
		it 'returns the associated extensions' do
			@user = get_lecturer_with_units_projects_teams
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

			assignment = @user.assignments[0]
			iteration = FactoryGirl.create(:iteration, assignment_id: assignment.id)
			pa_form = FactoryGirl.create(:pa_form, iteration_id: iteration.id)
			project = @user.assignments[0].projects[0]
			extension = FactoryGirl.create(:extension, project_id: project.id, deliverable_id: pa_form.id)
			extension_other = FactoryGirl.create(:extension)
			expect(@current_user.extensions.length).to eq(1)
			expect(@current_user.extensions[0]).to eq(extension)
		end
	end
end
