class IncludesCompact::DepartmentSerializer < DepartmentSerializer
	has_many :units, serializer: Compact::UnitSerializer
end
