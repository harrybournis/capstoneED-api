module PointsAward::Awarders
  class LogAwarder < PointsAward::Awarder
    include Waterfall

    def initialize(points_board)
      super points_board
    end

    def call
      @points_board.add(:log, { points: 10, reason_id: 1, resource_id: 6 })
      @points_board
    end
  end
end
