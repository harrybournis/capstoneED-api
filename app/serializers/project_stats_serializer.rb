class ProjectStatsSerializer < ActiveModel::Serializer
	attributes :project_health, :team_health
end
