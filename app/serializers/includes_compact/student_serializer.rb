class IncludesCompact::StudentSerializer < StudentSerializer
	has_many :teams, serializer: Base::BaseSerializer
	has_many :projects, serializer: Base::BaseSerializer
end
