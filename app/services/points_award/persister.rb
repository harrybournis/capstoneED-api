module PointsAward
  class Persister
    include Waterfall

    def initialize(points_board)
      @points_board = points_board
    end
  end
end
