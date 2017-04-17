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

  # Serializes the resource with the points in the points board to
  # include a "points" field in the response. If the PointsBoard has
  # not pesisted it does not include "points" in the response.
  #
  # @param resource [Object] The aboject tha wiil be serialized
  # @param points_board [PoinstBoard] The pointsboard containing the
  #   points earned.
  #
  # @return [JSON] The json response.
  #
  def serialize_w_points(resource, points_board)
    resource_json = ActiveModelSerializers::SerializableResource.new(resource).as_json
    return resource unless points_board.persisted?

    points_json = ActiveModelSerializers::SerializableResource.new(points_board, serializer: PointsAward::PointsBoardSerializer).as_json
    resource_json.merge(points_json)
  end
end
