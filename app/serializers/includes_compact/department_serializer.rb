class IncludesCompact::DepartmentSerializer < DepartmentSerializer
	has_many :units, serializer: Base::BaseSerializer
end
