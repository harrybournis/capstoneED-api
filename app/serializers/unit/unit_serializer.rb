class Unit::UnitSerializer < Base::BaseSerializer
  attributes :id, :name, :code, :semester, :year, :archived_at # add department
end
