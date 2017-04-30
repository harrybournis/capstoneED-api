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

    # Gives points for completing a log. Checks if the
    # max_logs_per_day limit has been reached for this
    # project, and if it has it gives no points for 24 hours.
    # For each log after the first one, it gives gradually
    # less points, before reaching 0.
    #
    # @return [Hash] Points
    #
    def points_for_log
      points = @game_setting.points_log

      max_logs = @game_setting.max_logs_per_day
      current_num = 0

      @students_project.logs.last(max_logs + 1).each do |log|
        # tried this with .today? method, but some kind of bug
        # kept saying that DateTime.now was not today in testing.
        # This works in every case.
        current_num += 1 if DateTime.now.to_i - Time.at(log['date_submitted'].to_i).to_i <= 1.day.to_i

        return if current_num > max_logs
      end

      if current_num > 1
        points = points - ((points / max_logs) * (current_num - 1))
      end

      {
        points: points,
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
    # for the curren iteration.
    #
    # @return [Hash] Points.
    #
    def first_of_team
      found_logs = false

      current_iteration  = @students_project.project.current_iterations[0]
      StudentsProject.where(project_id: @students_project.project_id).each do |sp|
        if sp.student_id != @student.id
          if sp.logs.any? && current_iteration.duration.cover?(Time.at(sp.logs[-1]['date_submitted'].to_i))
            found_logs = true
            break
          end
        end
      end

      return if found_logs
      {
        points: @game_setting.points_log_first_of_team,
        reason_id: Reason[:log_first_of_team][:id]
      }
    end

    # Gives points for submitting a log first in the assignment
    # for the current iteration.
    #
    # @return [Hash] Points.
    #
    def first_of_assignment
      found_logs = false

      current_iteration = @students_project.project.current_iterations[0]
      @students_project.project.assignment.students_projects.each do |sp|
        if sp.student_id != @student.id
          if sp.logs.any? && current_iteration.duration.cover?(Time.at(sp.logs[-1]['date_submitted'].to_i))
            found_logs = true
            break
          end
        end
      end

      return if found_logs
      {
        points: @game_setting.points_log_first_of_assignment,
        reason_id: Reason[:log_first_of_assignment][:id]
      }
    end
  end
end
