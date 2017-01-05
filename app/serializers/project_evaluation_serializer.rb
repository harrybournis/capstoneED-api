class ProjectEvaluationSerializer < Base::BaseSerializer
	attributes :user_id, :project_id, :iteration_id, :feeling, :percent_complete, :date_submitted

	def feeling
		object.feeling.name
	end
end
