require 'rails_helper'

RSpec.describe V1::PointsController, type: :controller do

  before :all do
    @lecturer = create :lecturer_confirmed
    @student = create :student_confirmed
    @unit = create :unit, lecturer: @lecturer
    @assignment = create :assignment, lecturer: @lecturer, unit: @unit
    @project = create :project, assignment: @assignment
  end

  describe 'index_for_project' do

    describe 'Student' do

      before :each do
        @controller = V1::PointsController.new
        mock_request = MockRequest.new(valid = true, @student)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
      end

      it "response contains 'personal', 'team_average', 'team_points'", { docs?: true, lecturer?: false } do
        expect(create :students_project_with_points, project: @project, student: @student, points: 10).to be_truthy
        expect(create :students_project_with_points, project: @project, points: 20).to be_truthy
        expect(create :students_project_with_points, project: @project, points: 30).to be_truthy

        get :index_for_project, params: { project_id: @project.id }

        expect(status).to eq 200

        expect(body['points']['personal']).to eq @student.points_for_project_id(@project.id)
        expect(body['points']['team_average']).to eq @project.team_average
        expect(body['points']['team_points']).to eq @project.team_points
      end

      it 'each field is 0 if there are no points' do
        create :students_project_with_points, project: @project, student: @student, points: 0
        create :students_project_with_points, project: @project, points: 0
        create :students_project_with_points, project: @project, points: 0
        @project.reload

        get :index_for_project, params: { project_id: @project.id }

        expect(status).to eq 200

        expect(body['points']['personal']).to eq 0
        expect(body['points']['team_average']).to eq 0
        expect(body['points']['team_points']).to eq 0
      end

      it 'returns 403 if user is not associated with the project' do
        project2 = create :project

        get :index_for_project, params: { project_id: project2.id }

        expect(status).to eq 403
        expect(errors_base[0]).to include 'not associated'
      end
    end

    describe 'Lecturer' do

      before :each do
        @controller = V1::PointsController.new
        mock_request = MockRequest.new(valid = true, @lecturer)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
      end

      it "response contains 'team_average', 'team_points'", { docs?: true } do
        create :students_project_with_points, project: @project, student: @student
        create :students_project_with_points, project: @project
        create :students_project_with_points, project: @project

        get :index_for_project, params: { project_id: @project.id }

        expect(status).to eq 200

        expect(body['points']['personal']).to be_falsy
        expect(body['points']['team_average']).to eq @project.team_average
        expect(body['points']['team_points']).to eq @project.team_points
      end

      it 'returns 403 if user is not associated with the project' do
        project2 = create :project

        get :index_for_project, params: { project_id: project2.id }

        expect(status).to eq 403
        expect(errors_base[0]).to include 'not associated'
      end
    end
  end

  describe 'index_for_assignment' do
    describe 'Student' do

      before :each do
        @controller = V1::PointsController.new
        mock_request = MockRequest.new(valid = true, @student)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
      end

      it "response contains array of hashes with 'project_id', 'team_name', 'points' and 'my_team'", { docs?: true, lecturer?: false } do
        create :students_project_with_points, project: @project, student: @student
        create :project, assignment: @assignment
        create :project, assignment: @assignment
        @assignment.reload

        get :index_for_assignment, params: { assignment_id: @assignment.id }

        expect(status).to eq 200
        expect(body['points']).to be_an Array
        expect(body['points'].length).to eq @assignment.projects.count
        expect(body['points'][0]['project_id']).to be_truthy

        body['points'].each do |points|
          project_id = points['project_id']
          expect(points['team_name']).to eq Project.find(project_id).team_name
          expect(points['team_points']).to eq Project.find(project_id).team_points
          if points['project_id'] == @project.id
            expect(points['my_team']).to be true
          else
            expect(points['my_team']).to be_falsy
          end
        end
      end

      it 'returns 403 if user is not associated with the assignment' do
        assignment2 = create :assignment

        get :index_for_assignment, params: { assignment_id: assignment2.id }

        expect(status).to eq 403
        expect(errors_base[0]).to include 'not associated'
      end
    end

    describe 'Lecturer' do

      before :each do
        @controller = V1::PointsController.new
        mock_request = MockRequest.new(valid = true, @lecturer)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
      end

      it "response contains array of hashes with 'project_id', 'team_name' and 'points'", { docs?: true } do
        create :project, assignment: @assignment
        create :project, assignment: @assignment
        @assignment.reload

        get :index_for_assignment, params: { assignment_id: @assignment.id }

        expect(status).to eq 200
        expect(body['points']).to be_an Array
        expect(body['points'].length).to eq @assignment.projects.count
        expect(body['points'][0]['project_id']).to be_truthy

        body['points'].each do |points|
          project_id = points['project_id']
          expect(points['team_name']).to eq Project.find(project_id).team_name
          expect(points['team_points']).to eq Project.find(project_id).team_points
          expect(points['my_team']).to be_falsy
        end
      end

      it 'returns 403 if user is not associated with the assignment' do
        assignment2 = create :assignment

        get :index_for_assignment, params: { assignment_id: assignment2.id }

        expect(status).to eq 403
        expect(errors_base[0]).to include 'not associated'
      end
    end
  end
end
