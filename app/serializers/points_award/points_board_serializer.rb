class PointsAward::PointsBoardSerializer < ActiveModel::Serializer
  attributes :points_earned,  :new_total, :detailed

  def points_earned
    object.total_points
  end

  def new_total
    object.student.points_for_project_id(object.points_persisted[0].project_id)
  end

  def detailed
    #array = []
    # object.points_persisted.each do |p|
    #   array << ActiveModelSerializers::SerializableResource.new(p, serializer: PointsAward::PointObjectSerializer).as_json
    # end
    #array
    object.points
  end

  def persisted?
    object.persisted?
  end

  type 'points'
end
