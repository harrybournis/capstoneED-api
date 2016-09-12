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

		describe 'Teams' do
			before(:each) do
				@controller = V1::TeamsController.new
			end

			it 'GET index can include lecturer' do
				get :index, params: { includes: 'students,project,lecturer', compact: true }
				expect(status).to eq(200)
				expect(body['teams'].first['students'].first).to_not include('email', 'provider')
				expect(body['teams'].length).to eq(2)
				expect(body['teams'].first['project']).to_not include('description')
				expect(body['teams'].first['project']['id']).to eq(@project2.id)
				expect(body['teams'].first['lecturer']).to include('id')
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
	end
end
