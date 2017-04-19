# Module for the points award service classes.
#
# @author [harrybournis]
#
module PointsAward
  # The Awarder awards points according to specific business rules.
  # It returs a PointsBoard object containing the awarder points.
  # The hash_key method determines the key that will be used to
  # store the points in the points hash of the pointsboard.
  #
  # @author [harrybournis]
  #
  class Awarder
    include Waterfall

    # Constructor. Takes a PointsBoard, which will be updated
    # with points according to the business rules.
    #
    # @param points_board [PointsBoard] A Pointsboard object that
    #   will be used to save the points.
    #
    # @return [PointsAward::Awarder]
    #
    def initialize(points_board)
      @points_board = points_board
    end

    # Executes the action of the awarder. Calls all the
    # public methods in the class except for :call (this method),
    # and the :hash_key method. Any method that does not return
    # points should be made private to avoid being called by this
    # method.
    #
    # @return [PointsBoard] Returns the points board which has
    #   been updated with points by the various public methods of the
    #   class.
    #
    def call
      public_methods(false).each do |method|
        unless method == :call || method == :hash_key
          result = self.send(method)
          @points_board.add(hash_key, result) if result
        end
      end

      @points_board
    end

    # States the key that the awarder will use to save the points
    # in the PointsBoard. Intentionally left to throw an
    # exception as any subclasses must define their own key.
    #
    # @raise [ArgumentError] Raises an Error if not overriden by
    #   the subclass.
    #
    def hash_key
      raise ArgumentError, 'You must define the hash_key method in the subclass that sets the key of the points.'
    end
  end
end
