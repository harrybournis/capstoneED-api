class ProjectEvaluationSerializer < Base::BaseSerializer
	attributes :user_id, :project_id, :iteration_id, :percent_complete, :date_submitted
end
