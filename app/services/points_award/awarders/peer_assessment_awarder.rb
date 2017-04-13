module PointsAward::Awarders

  class PeerAssessmentAwarder < PointsAward::Awarder
    include Waterfall

    def initialize(points_board)
      @points_board = points_board
    end

    def call
      @points_board.add(:peer_assessment, { points: 10, reason: 1, resource_id: 6 })
      @points_board
    end
  end
end
