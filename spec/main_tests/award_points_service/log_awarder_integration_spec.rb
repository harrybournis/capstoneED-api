require 'rails_helper'

RSpec.describe "LogPointAwarder - Integration", type: :request do

  before(:each) do
    host! 'api.example.com'

    now = DateTime.now
    @assignment = create :assignment, start_date: now - 2.months, end_date: now + 2.months
    @iteration1 = create :iteration, assignment: @assignment, start_date: @assignment.start_date, deadline: now + 1.month
    @iteration2 = create :iteration, assignment: @assignment, start_date: now + 1.month + 1.minute, deadline: @assignment.end_date
    @game_setting  = create :game_setting, assignment: @assignment, points_log: 10, max_logs_per_day: 3
    @project = create :project, assignment: @assignment
    @student = create :student_confirmed
    @students_project = create :students_project, student: @student, project: @project
    @project = @student.projects[0]
    @valid_params = build(:students_project).logs[0].except(:date_submitted).merge(id: @project.id)
    @valid_log_entry = JSON.parse({ date_worked: (DateTime.now - 1.day).to_i.to_s, date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json)
    @invalid_params = build(:students_project).logs[0].except("date_submitted", "time_worked").merge(id: @project.id)
    @invalid_log_entry = JSON.parse({ date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json)

    post '/v1/sign_in', params: { email: @student.email, password: '12345678' }
    expect(response.status).to eq(200)
    @csrf = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
  end

  describe 'Success' do
    it 'gives full points on submission' do
      Timecop.travel(DateTime.now + 5.days) do
        @student, @csrf = login_integration @student

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

        expect(status).to eq 201
        @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).last
        expect(@point.points).to eq @game_setting.points_log
      end
    end

    it 'gives less points subsequent submission of the day before the limit' do
      @students_project.logs = []
      @students_project.save

      Timecop.travel(DateTime.now + 5.days) do
        @student, @csrf = login_integration @student

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }
        expect(status).to eq 201
        @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).last
        expect(@point.points).to eq @game_setting.points_log

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }
        expect(status).to eq 201
        @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).last
        expect(@point.points).to eq @game_setting.points_log - (@game_setting.points_log / @game_setting.max_logs_per_day)

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }
        expect(status).to eq 201
        @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).last
        expect(@point.points).to eq @game_setting.points_log - ((@game_setting.points_log / @game_setting.max_logs_per_day) * 2)
      end
    end

    it 'does not give after the max limit' do
      @students_project.logs = []
      @students_project.save
      now = DateTime.now

      Timecop.travel(now + 5.days) do
        @student, @csrf = login_integration @student

        @game_setting.max_logs_per_day.times do
          expect {
            post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
          }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

          expect(status).to eq 201
        end

        @students_project.reload
        expect(@students_project.logs.length).to eq @game_setting.max_logs_per_day

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to_not change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

        expect(status).to eq 201
      end
    end

    it 'resets after a day' do
      @students_project.logs = []
      @students_project.save
      now = DateTime.now

      Timecop.travel(now + 5.days) do
        @student, @csrf = login_integration @student

        @game_setting.max_logs_per_day.times do
          expect {
            post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
          }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

          expect(status).to eq 201
        end

        @students_project.reload
        expect(@students_project.logs.length).to eq @game_setting.max_logs_per_day

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to_not change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

        expect(status).to eq 201

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to_not change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

        expect(status).to eq 201

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to_not change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

        expect(status).to eq 201
      end

      Timecop.travel(now + 6.days + 2.hours) do
        @student, @csrf = login_integration @student

        @game_setting.max_logs_per_day.times do
          expect {
            post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
          }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

          expect(status).to eq 201
        end

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to_not change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

        expect(status).to eq 201
      end
    end

    it 'gives points on submission of first log of day' do
      Timecop.travel(DateTime.now + 5.days) do
        @student, @csrf = login_integration @student

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_day][:id]).count }

        expect(status).to eq 201
        @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_day][:id]).last
        expect(@point.points).to eq @game_setting.points_log_first_of_day
      end
    end

    it 'gives points on submission of first log of day if no other log exists' do
      @students_project.logs = []
      @students_project.save

      Timecop.travel(DateTime.now + 5.days) do
        @student, @csrf = login_integration @student

        expect {
          post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_day][:id]).count }

        expect(status).to eq 201
        @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_day][:id]).last
        expect(@point.points).to eq @game_setting.points_log_first_of_day
      end
    end

    # it 'gives points if submitted first in the team for each iteration' do
      # @students_project.logs = []
      # @students_project.save
      # @student2 = create :student_confirmed
      # @sp2 = create :students_project, project: @project, student: @student2
      # @sp2.logs = []
      # @sp2.save
#
      # expect {
        # post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
      # }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_team][:id]).count }
#
      # expect(status).to eq 201
      # @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_team][:id]).last
      # expect(@point.points).to eq @game_setting.points_log_first_of_team
#
      # Timecop.travel @iteration2.start_date + 1.day do
        # @student, @csrf = login_integration @student
#
        # expect {
          # post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        # }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_team][:id]).count }
#
      # end
    # end

    # it 'gives points if submitted first in the assignment for each iteration' do
      # @students_project.logs = []
      # @students_project.save
      # @student2 = create :student_confirmed
      # @project2 = create :project, assignment: @assignment
      # @sp2 = create :students_project, project: @project2, student: @student2
      # @sp2.logs = []
      # @sp2.save
#
      # expect {
        # post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
      # }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_assignment][:id]).count }
#
      # expect(status).to eq 201
      # @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_assignment][:id]).last
      # expect(@point.points).to eq @game_setting.points_log_first_of_assignment
#
      # Timecop.travel @iteration2.start_date + 1.day do
        # @student, @csrf = login_integration @student
#
        # expect {
          # post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        # }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_assignment][:id]).count }
      # end
    # end
  end

  describe 'Failure' do
    it 'does not give points if invalid log submission' do
      expect {
        post "/v1/projects/#{@project.id}/logs", params: @invalid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to_not change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

      expect(status).to eq 422
    end

    it 'does not give points if log not first log of day' do
      @students_project.add_log @valid_log_entry
      expect(@students_project.save).to be_truthy

      expect {
        post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to_not change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_day][:id]).count }

      expect(status).to eq 201
      @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_day][:id]).last
      expect(@point).to be_falsy
    end

    it 'does not give points if not first of team' do
      @students_project.logs = []
      @students_project.save
      @student2 = create :student_confirmed
      @sp2 = create :students_project, project: @project, student: @student2

      expect {
        post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to_not change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_team][:id]).count }

      expect(status).to eq 201
      @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_team][:id]).last
      expect(@point).to be_falsy
    end

    # it 'does not give points if not first of assignment' do
      # @students_project.logs = []
      # @students_project.save
      # @student2 = create :student_confirmed
      # @project2 = create :project, assignment: @assignment
      # @sp2 = create :students_project, project: @project2, student: @student2
#
      # expect {
        # post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
      # }.to_not change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_assignment][:id]).count }
#
      # expect(status).to eq 201
      # @point = LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_assignment][:id]).last
      # expect(@point).to be_falsy
#
      # Timecop.travel @iteration2.start_date + 1.day do
        # @student, @csrf = login_integration @student
#
        # expect {
          # post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        # }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log_first_of_assignment][:id]).count }
      # end
    # end
  end

  # describe 'Profile points get updated' do
    # it 'with points for log, first of team, first of assignment' do
      # @students_project.logs = []
      # @students_project.save
      # expect(@student.points_for_project_id(@project.id)).to eq 0
#
      # Timecop.travel(DateTime.now + 5.days) do
        # @student, @csrf = login_integration @student
#
        # expect {
          # post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
        # }.to change {
          # @student.points_for_project_id(@project.id)
        # }.to(@game_setting.points_log +
             # @game_setting.points_log_first_of_team +
             # @game_setting.points_log_first_of_day +
             # @game_setting.points_log_first_of_assignment)
#
        # expect(status).to eq 201
      # end
    # end
  # end

  describe 'Serialization' do
    it 'includes points in the json response' do
      expect(@student.points_for_project_id(@project.id)).to eq 0

      expect {
        post "/v1/projects/#{@project.id}/logs", params: @valid_params, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to change { LogPoint.where(student_id: @student.id, reason_id: Reason[:log][:id]).count }

      expect(status).to eq 201

      new_points = 0
      LogPoint.where(student_id: @student.id).each do |pap|
        new_points += pap.points
      end
      expect(@student.points_for_project_id(@project.id)).to eq new_points

      expect(body['points']).to be_truthy
      expect(body['points']['points_earned']).to eq new_points
      expect(body['points']['new_total']).to eq @student.points_for_project_id(@project.id)
      expect(body['points']['detailed']['log']).to be_a Array
      expect(body['points']['detailed']['log'].length).to eq LogPoint.where(student_id: @student.id).count
      expect(body['points']['detailed']['log'][0]['reason_id']).to be_truthy
      expect(body['points']['detailed']['log'][0]['points']).to be_truthy
    end

    it 'does not include points in the response if the request was invalid' do
      expect {
        post "/v1/projects/#{@project.id}/logs", params: @invalid_log_entry, headers: { 'X-XSRF-TOKEN' => @csrf }
      }.to_not change { LogPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment_first_of_assignment][:id]).count }

      expect(status).to eq 422

      expect(body['points']).to be_falsy
    end
  end
end
