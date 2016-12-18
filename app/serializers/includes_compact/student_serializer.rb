class IncludesCompact::StudentSerializer < StudentSerializer
	has_many :projects, serializer: Base::BaseSerializer
	has_many :assignments, serializer: Base::BaseSerializer
end
