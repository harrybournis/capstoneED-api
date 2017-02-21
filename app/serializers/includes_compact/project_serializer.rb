class IncludesCompact::ProjectSerializer < ProjectSerializer
	belongs_to 	:assignment, serializer: Compact::AssignmentSerializer
	belongs_to 	:unit, 			serializer: Compact::UnitSerializer
	has_many 		:students, serializer: Base::BaseSerializer
	has_one			:lecturer, serializer: Base::BaseSerializer
end
