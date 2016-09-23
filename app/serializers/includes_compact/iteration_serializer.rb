class IncludesCompact::IterationSerializer < IterationSerializer
	has_one :pa_form, serializer: Base::BaseSerializer
end
