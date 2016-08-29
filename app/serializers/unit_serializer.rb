class UnitSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :semester, :year, :archived_at # add department
end
