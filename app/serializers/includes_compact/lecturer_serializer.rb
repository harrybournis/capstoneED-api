class IncludesCompact::LecturerSerializer < LecturerSerializer
	has_many :units, serializer: Base::BaseSerializer
	has_many :assignments, serializer: Base::BaseSerializer
end
