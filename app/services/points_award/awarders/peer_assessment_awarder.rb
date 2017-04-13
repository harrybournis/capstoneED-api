module PointsAward::Awarders

  class PeerAssessmentAwarder < PointsAward::Awarder

    def initialize(points_board)
      super points_board
      @student = @points_board.student
      @peer_assessment = @points_board.resource
      @game_setting = @peer_assessment.assignment.game_setting
    end

    # Needed in order to identify the points in the points_board
    #
    # @return [Hash] The key that should be used to save the points
    #   in the points hash of the PointsBoard
    #
    def hash_key
      :peer_assessment
    end

    # Points awarded for submitting a peer assessment
    #
    # @return [Hash] The points
    #
    def points_for_submitting
      {
        points: @game_setting.points_peer_assessment,
        reason_id: Reason[:peer_assessment][:id],
        resource_id: @points_board.resource.id
      }
    end

    # Points awarded for submitting the peer assessment before
    # everyone in the team.
    #
    # @return [Hash | nil] The points or nil if not the first one.
    #
    def points_for_first_in_team
      if PeerAssessment.where(pa_form_id: @peer_assessment.pa_form_id,
                              project_id: @peer_assessment.project_id).count == 1
        {
          points: @game_setting.points_peer_assessment_first_of_team,
          reason_id: Reason[:peer_assessment_first_of_team][:id],
          resource_id: @points_board.resource.id
        }
      end
    end

    # Points awarded for submitting the peer asssessment before
    # everyone in all the teams of the assignment.
    #
    # @return [Hash | nil] The points or nil if not the first one.
    #
    def points_for_first_in_assignment
      if PeerAssessment.where(pa_form_id: @peer_assessment.pa_form_id).count == 1
        {
          points: @game_setting.points_peer_assessment_first_of_assignment,
          reason_id: Reason[:peer_assessment_first_of_assignment][:id],
          resource_id: @points_board.resource.id
        }
      end
    end

    private

  end
end
