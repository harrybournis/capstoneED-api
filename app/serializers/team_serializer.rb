class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo, :enrollment_key
end
