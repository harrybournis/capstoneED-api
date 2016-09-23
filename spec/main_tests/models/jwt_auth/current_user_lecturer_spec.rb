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
end