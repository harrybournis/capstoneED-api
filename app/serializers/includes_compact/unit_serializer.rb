class IncludesCompact::UnitSerializer < UnitSerializer
	belongs_to 	:department, serializer: Base::BaseSerializer
	has_many 		:assignments, serializer: Base::BaseSerializer
	has_one 		:lecturer, serializer: Base::BaseSerializer
end
