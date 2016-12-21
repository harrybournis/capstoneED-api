class ProjectEvaluationSerializer < ProjectEvaluationSerializer
	belongs_to :project,		serializer: Base::BaseSerializer
	belongs_to :iteration, 	serializer: Base::BaseSerializer
	belongs_to :user, 			serializer: Base::BaseSerializer
end
