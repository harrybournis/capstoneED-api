require 'rails_helper'
require 'helpers/mock_request.rb'
#include JWTAuth::JWTAuth::JWTAuthenticator

RSpec.describe JWTAuth::CurrentUserStudent, type: :model do

	describe 'Projects' do

		before(:each) do
			@user = FactoryGirl.create(:student)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserStudent.new(@token_id, 'Student', @device)

			lecturer = FactoryGirl.create(:lecturer)
			@unit = FactoryGirl.create(:unit, lecturer: lecturer)
			@project = FactoryGirl.create(:project_with_teams, unit: @unit, lecturer: lecturer)
			3.times { @project.teams.first.students << FactoryGirl.build(:student) }
			Team.first.students << @user
			expect(@user.projects.length).to eq(1)
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
				@project_find[0].unit if (@project_find = @current_user.projects(includes: ['unit']).where(unit_id: @unit)).length > 0
			}.to make_database_queries(count: 1)
			expect(@project_find[0].unit).to eq(@unit)
		end
	end

	describe 'Units' do
		before(:all) do
			@user = FactoryGirl.create(:lecturer)
			@other_unit = FactoryGirl.create(:unit)
			@unit = FactoryGirl.create(:unit, lecturer: @user)
			@project = FactoryGirl.create(:project_with_teams, unit: @user.units[0], lecturer: @user)
		end
		before(:each) do
			@user = FactoryGirl.create(:student)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserStudent.new(@token_id, 'Student', @device)

			@project.teams.first.students << @user
		end

		it 'loads the correct units' do
			@units = @current_user.units
			res = true
			@units.each { |u| res = false unless @current_user.units.include? u }
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
				(@units = @current_user.units(includes: ['projects'])).length
			}.to make_database_queries(count: 1)
			expect {
				@units[0].projects[0].start_date
			}.to_not make_database_queries
		end
	end

	describe 'PAForms' do
		it 'returns correct pa_forms' do
			@user = FactoryGirl.create(:lecturer)
			@student = FactoryGirl.create(:student)
			@request = MockRequest.new(valid = true, @student)
			decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user = JWTAuth::CurrentUserStudent.new(@token_id, 'Student', @device)

			@unit = FactoryGirl.create(:unit, lecturer: @user)
			@project = FactoryGirl.create(:project_with_teams, unit: @unit, lecturer: @user)
			@team = FactoryGirl.create(:team, project_id: @project.id)
			@team.students << @student

			iteration = FactoryGirl.create(:iteration, project_id: @project.id)
			iteration2 = FactoryGirl.create(:iteration, project_id: @project.id)
			pa_form = FactoryGirl.create(:pa_form, iteration: iteration)
			pa_form2 = FactoryGirl.create(:pa_form, iteration: iteration2)
			expect(@current_user.pa_forms.length).to eq(2)
		end
	end
end
