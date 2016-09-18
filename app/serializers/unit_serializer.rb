class UnitSerializer < Base::BaseSerializer
  attributes :id, :name, :code, :semester, :year, :archived_at

  belongs_to :department
end
