class IncludesCompact::LecturerSerializer < LecturerSerializer
	has_many :units, serializer: Compact::UnitSerializer
	has_many :assignments, serializer: Base::BaseSerializer
end
