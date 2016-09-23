class IncludesCompact::PAFormSerializer < Base::BaseSerializer
	belongs_to :iteration, serializer: Base::BaseSerializer
end
