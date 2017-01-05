class ProjectSerializer < Base::BaseSerializer
  attributes :id, :project_name, :team_name, :description, :logo, :enrollment_key
end
