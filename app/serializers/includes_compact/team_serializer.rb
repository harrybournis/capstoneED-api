class IncludesCompact::TeamSerializer < TeamSerializer
	belongs_to 	:project, serializer: Base::BaseSerializer
	has_many 		:students, serializer: Base::BaseSerializer
end
