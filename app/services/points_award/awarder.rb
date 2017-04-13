module PointsAward

  # The Awarder awards points according to specific business rules.
  # It returs a PointsBoard object containing the awarder points.
  #
  # @author [harrybournis]
  #
  class Awarder
    include Waterfall

    def initialize(points_board)
      @points_board = points_board
    end

    def call
      public_methods(false).each do |method|
        unless method == :call || method == :hash_key
          result = self.send(method)
          @points_board.add(hash_key, result) if result
        end
      end

      @points_board
    end

    def hash_key
      raise ArgumentError, 'You must define the hash_key method in the subclass that sets the key of the points.'
    end
  end
end
