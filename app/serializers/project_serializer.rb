class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :end_date, :description

  has_one :unit
end
