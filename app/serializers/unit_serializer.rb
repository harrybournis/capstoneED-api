class UnitSerializer < Base::BaseSerializer
  attributes :id, :name, :code, :semester, :year, :archived_at, :department_id

  belongs_to :department
end
