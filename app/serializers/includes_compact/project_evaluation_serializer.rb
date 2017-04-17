class IncludesCompact::ProjectEvaluationSerializer < ProjectEvaluationSerializer
	belongs_to :project,		serializer: Base::BaseSerializer
	belongs_to :iteration, 	serializer: Base::BaseSerializer
	belongs_to :user, 			serializer: Base::BaseSerializer
	belongs_to :feeling, 			serializer: Base::BaseSerializer
end
