class IncludesCompact::UnitSerializer < UnitSerializer
	belongs_to 	:department, serializer: Base::BaseSerializer
	has_many 		:assignments, serializer: Compact::AssignmentSerializer
	has_one 		:lecturer, serializer: Base::BaseSerializer
end
