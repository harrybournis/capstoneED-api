require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe JWTAuth::CurrentUserLecturer, type: :model do

	describe 'Projects' do

		before(:each) do
			@user = FactoryGirl.create(:lecturer)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

			@unit = FactoryGirl.create(:unit, lecturer: @user)
			@project = FactoryGirl.create(:project_with_teams, unit: @unit, lecturer: @user)
			3.times { @project.teams.first.students << FactoryGirl.build(:student) }
		end

		it 'loads the correct projects' do
			expect {
				(@projects = @current_user.projects).length
			}.to make_database_queries(count: 1)
			expect(@projects.length).to eq(@current_user.load.projects.length)
		end

		it 'includes associations' do
			expect {
				@projects.length if @projects = @current_user.projects(includes: 'unit')
			}.to make_database_queries(count: 1)
			expect {
				unit = @projects[0].unit
			}.to_not make_database_queries

			expect {
				(@projects = @current_user.projects(includes: ['unit','teams'])).length
			}.to make_database_queries(count: 1)
			expect {
				teams = @projects[0].teams
			}.to_not make_database_queries
			expect {
				teams = @projects[0].unit
			}.to_not make_database_queries

			expect {
				(@projects = @current_user.projects(includes: ['lecturer','teams','students'])).length
			}.to make_database_queries(count: 1)
			expect {
				teams = @projects[0].lecturer
			}.to_not make_database_queries
			expect {
				teams = @projects[0].teams[0].students
			}.to_not make_database_queries
		end

		it 'can chain queries' do
			expect {
				@project_find[0].unit if (@project_find = @current_user.projects(includes: 'unit').where(unit_id: @unit)).length > 0
			}.to make_database_queries(count: 1)
			expect(@project_find[0].unit).to eq(@unit)
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
			@project = FactoryGirl.create(:project_with_teams, unit: @user.units[0], lecturer: @user)
			3.times { @project.teams.first.students << FactoryGirl.build(:student) }
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
				(@units = @current_user.units(includes: 'projects')).length
			}.to make_database_queries(count: 1)
			expect {
				@units[0].projects[0].start_date
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
			@project = FactoryGirl.create(:project_with_teams, unit: @unit, lecturer: @user)

			iteration = FactoryGirl.create(:iteration, project_id: @project.id)
			iteration2 = FactoryGirl.create(:iteration, project_id: @project.id)
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
			project = FactoryGirl.create(:project, lecturer_id: @user.id, unit: unit)
			iteration  = FactoryGirl.create(:iteration, project: project)
			pa_form = FactoryGirl.create(:pa_form, iteration: iteration)
			team = FactoryGirl.create(:team, project: project)
			student = FactoryGirl.create(:student_confirmed)
			student2 = FactoryGirl.create(:student_confirmed)
			student3 = FactoryGirl.create(:student_confirmed)
			team.students << student
			team.students << student2
			team.students << student3
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

			project = @user.projects[0]
			iteration = FactoryGirl.create(:iteration, project_id: project.id)
			pa_form = FactoryGirl.create(:pa_form, iteration_id: iteration.id)
			team = @user.projects[0].teams[0]
			extension = FactoryGirl.create(:extension, team_id: team.id, deliverable_id: pa_form.id)
			extension_other = FactoryGirl.create(:extension)
			expect(@current_user.extensions.length).to eq(1)
			expect(@current_user.extensions[0]).to eq(extension)

		end
	end
end
