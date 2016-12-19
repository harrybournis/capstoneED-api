class ProjectSerializer < Base::BaseSerializer
  attributes :id, :project_name, :team_name, :logo, :enrollment_key
end
