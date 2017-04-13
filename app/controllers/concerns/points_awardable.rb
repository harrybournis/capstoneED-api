# Methods that deal with the PointsAwardService
module PointsAwardable
  extend ActiveSupport::Concern

  # Calls PointsAwardService to award points for student's action.
  #
  # @param key [Symbol] The key that identifies the awarders.
  # @param resource = nil [Object] Optional. The resource
  #   associated with the points, if applicable.
  #
  # @return [PointsBoard] The resulting PointsBoard after processing.
  #
  def award_points(key, resource = nil, options = {})
    PointsAwardService.new(key, current_user, resource, options).call
  end

  def serialize_w_points(resource, points_board)
    resource
    # if points_board.errors?
    #   resource.errors
    # else
    #   resource
    # end
  end
end
