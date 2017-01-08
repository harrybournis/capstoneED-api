class IncludesCompact::ProjectStudentSerializer < ProjectStudentSerializer
	belongs_to 	:assignment, serializer: Base::BaseSerializer
	has_many 		:students, serializer: Base::BaseSerializer
	has_one			:lecturer, serializer: Base::BaseSerializer
end
