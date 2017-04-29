class Includes::ProjectEvaluationSerializer < ProjectEvaluationSerializer
	belongs_to :project
	belongs_to :iteration
	belongs_to :user
end
