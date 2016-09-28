class IncludesCompact::PeerAssessmentSerializer < PeerAssessmentSerializer
	belongs_to :pa_form, serializer: Base::BaseSerializer
	belongs_to :submitted_for, serializer: Base::BaseSerializer
	belongs_to :submitted_by, serializer: Base::BaseSerializer
end
