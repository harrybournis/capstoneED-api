module PointsAward::Awarders
  class ProjectEvaluationAwarder < PointsAward::Awarder
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

    # Points awarded for submitting the project evaluation before
    # everyone in all the teams of the assignment. The lecturer is not taken
    # into account if they have already submitted.
    #
    # @return [Hash | nil] The points or nil if not the first one.
    #
    def points_for_first_in_assignment
      evaluations = ProjectEvaluation.where(iteration_id: @project_evaluation.iteration_id)

      return unless evaluations.length <= 2

      if evaluations.length == 1 || evaluations.where.not(user_id: @student.id)[0].user.lecturer?
        {
          points: @game_setting.points_project_evaluation_first_of_assignment,
          reason_id: Reason[:project_evaluation_first_of_assignment][:id],
          resource_id: @points_board.resource.id
        }
      end
    end
  end
end
