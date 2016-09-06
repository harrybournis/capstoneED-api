class IncludesCompact::LecturerSerializer < LecturerSerializer
	has_many :units, serializer: Base::BaseSerializer
	has_many :projects, serializer: Base::BaseSerializer
end
