module PointsAward

  # Superclass for the points peristers.
  #
  # @author [harrybournis]
  #
  # @!attribute points_board
  #   @return [PointsBoard] The pointsboard containing the
  #     points that will be persisted.
  class Persister
    include Waterfall

    def initialize(points_board)
      @points_board = points_board
    end
  end
end
