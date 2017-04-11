module PointsAward::Persisters
  class DefaultPersister < PointsAward::Persister
    def initialize(points_board)
      @points_board = points_board
    end

    def call
      @points_board.persisted!
      @points_board
    end
  end
end
