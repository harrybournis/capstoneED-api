class PointsAward::PointObjectSerializer < ActiveModel::Serializer
  attributes :points, :reason_id
end
