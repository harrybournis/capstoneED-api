require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe JWTAuth::CurrentUser, type: :model do
	JWTAuthenticator = JWTAuth::JWTAuthenticator
	CurrentUser = JWTAuth::CurrentUser

	describe 'Scoped Associations' do

		describe 'Student' do

			describe 'Projects' do

				before(:each) do
					@user = FactoryGirl.create(:student)
					@request = MockRequest.new(valid = true, @user)
					decoded_token = JWTAuthenticator.decode_token(@request.cookies['access-token'])
					@token_id = decoded_token.first['id']
					@device = decoded_token.first['device']
					@current_user = CurrentUser.new(@token_id, 'Student', @device)

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
						(@projects = @current_user.projects(includes: 'unit,teams')).length
					}.to make_database_queries(count: 1)
					expect {
						teams = @projects[0].teams
					}.to_not make_database_queries
					expect {
						teams = @projects[0].unit
					}.to_not make_database_queries

					expect {
						(@projects = @current_user.projects(includes: 'lecturer,teams,students')).length
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
		end
	end
end
