class IncludesCompact::UnitSerializer < UnitSerializer
	belongs_to 	:department, serializer: Base::BaseSerializer
	has_many 		:projects, serializer: Base::BaseSerializer
end
