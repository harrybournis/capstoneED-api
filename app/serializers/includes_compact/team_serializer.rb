class IncludesCompact::TeamSerializer < TeamSerializer
	belongs_to 	:project, serializer: Base::BaseSerializer
	has_many 		:students, serializer: Base::BaseSerializer
	has_one			:lecturer, serializer: Base::BaseSerializer
end
