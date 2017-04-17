module PointsAward::Awarders
  class LogAwarder < PointsAward::Awarder
    include Waterfall

    def initialize(points_board)
      super points_board
      @student = @points_board.resource.student
      @log = @points_board.resource
      @students_project = @log.students_project
      @logs_length = @students_project.logs.length
      @game_setting = @log.project.assignment.game_setting
    end

    # Needed in order to identify the points in the points_board
    #
    # @return [Hash] The key that should be used to save the points
    #   in the points hash of the PointsBoard
    #
    def hash_key
      :log
    end

    # Gives points for completing a log.
    #
    # @return [Hash] Points
    #
    def points_for_log
      {
        points: @game_setting.points_log,
        reason_id: Reason[:log][:id]
      }
    end

    # Give points for completing the first log of the day.
    #
    # @return [Hash] Points
    #
    def first_of_day
      if @logs_length > 1
        logs = @students_project.logs.last(2)
        last_log = Time.at(logs[0]['date_submitted'].to_i).to_datetime
        current_log = Time.at(logs[1]['date_submitted'].to_i).to_datetime
        diff = TimeDifference.between(last_log, current_log).in_days
        return if diff <= 1
      end

      {
        points: @game_setting.points_log_first_of_day,
        reason_id: Reason[:log_first_of_day][:id]
      }
    end

    # Gives points for submtting a log first in the team
    #
    # @return [Hash] Points.
    #
    def first_of_team
      return if @logs_length > 1

      found_logs = false
       StudentsProject.where(project_id: @students_project.project_id).each do |sp|
        found_logs = true if sp.student_id != @student.id && sp.logs.any?
      end

      return if found_logs
      {
        points: @game_setting.points_log_first_of_team,
        reason_id: Reason[:log_first_of_team][:id]
      }
    end

    # Gives points for submitting a log first in the assignment
    #
    # @return [Hash] Points.
    #
    def first_of_assignment
      return if @logs_length > 1

      found_logs = false
       StudentsProject.where(project_id: @log.project.assignment.projects.select(:id)).each do |sp|
        found_logs = true if sp.student_id != @student.id && sp.logs.any?
      end

      return if found_logs
      {
        points: @game_setting.points_log_first_of_assignment,
        reason_id: Reason[:log_first_of_assignment][:id]
      }
    end
  end
end
