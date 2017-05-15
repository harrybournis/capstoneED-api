module PointsAward::Awarders
  class ProjectEvaluationAwarder < PointsAward::Awarder
    include ApiHelper

    def initialize(points_board)
      super points_board
      @student = @points_board.student
      @project_evaluation = @points_board.resource
      @game_setting = @project_evaluation.project.assignment.game_setting
    end

    # Needed in order to identify the points in the points_board
    #
    # @return [Hash] The key that should be used to save the points
    #   in the points hash of the PointsBoard
    #
    def hash_key
      :project_evaluation
    end

    # Points awarded for submitting a project evaluation
    #
    # @return [Hash] The points
    #
    def points_for_submitting
      {
        points: @game_setting.points_project_evaluation,
        reason_id: Reason[:project_evaluation][:id],
        resource_id: @points_board.resource.id
      }
    end

    # Points awarded for submitting the project evaluation before
    # everyone in the team. The lecturer is not take into account
    # if they have already submitted.
    #
    # @return [Hash | nil] The points or nil if not the first one.
    #
    def points_for_first_in_team
      evaluations = ProjectEvaluation.where(project_id: @project_evaluation.project_id,
                                            iteration_id: @project_evaluation.iteration_id)
      return unless evaluations.length <= 2

      if evaluations.length == 1 || evaluations.where.not(user_id: @student.id)[0].user.lecturer?
        {
          points: @game_setting.points_project_evaluation_first_of_team,
          reason_id: Reason[:project_evaluation_first_of_team][:id],
          resource_id: @points_board.resource.id
        }
      end
    end

    # Points awarded of submitting the project evaluation during
    # the first day of it being available.
    #
    # @return [Hash | nil] The points or nil if not in the first
    #   day.
    #
    def points_for_submit_in_the_first_day
      iteration_start = @project_evaluation.iteration.start_date.to_i
      iteration_end = @project_evaluation.iteration.deadline.to_i
      now = DateTime.now.to_i
      progress = calculate_progress(@project_evaluation.date_submitted.to_i, iteration_start, iteration_end)

      ProjectEvaluation::NO_OF_EVALUATIONS_PER_ITERATION.times do |n|
        upper = (1.0 / (n + 1)).round 1
        lower = upper - 0.1

        if progress.between?(lower, upper)
          start_date = Time.at(iteration_start + ((iteration_end - iteration_start) * lower)).to_datetime
          if @project_evaluation.date_submitted <= start_date + 1.day
            return {
              points: @game_setting.points_project_evaluation_submitted_first_day,
              reason_id: Reason[:project_evaluation_submitted_first_day][:id],
              resource_id: @points_board.resource.id
            }
          end
        end
      end
      nil
    end

    # Points awarded for submitting the project evaluation before
    # everyone in all the teams of the assignment. The lecturer is not taken
    # into account if they have already submitted.
    #
    # @return [Hash | nil] The points or nil if not the first one.
    #
    # def points_for_first_in_assignment
    # evaluations = ProjectEvaluation.where(iteration_id: @project_evaluation.iteration_id)
    #
    # return unless evaluations.length <= 2
    #
    # if evaluations.length == 1 || evaluations.where.not(user_id: @student.id)[0].user.lecturer?
    # {
    # points: @game_setting.points_project_evaluation_first_of_assignment,
    # reason_id: Reason[:project_evaluation_first_of_assignment][:id],
    # resource_id: @points_board.resource.id
    # }
    # end
    # end
  end

  private

    def calculate_progress(x, min, max)
      ((x - min) / (max - min).to_f).round(1)
    end
end
