class ProjectSerializer < Base::BaseSerializer
  attributes :id, :assignment_id, :project_name, :team_name, :description,
   :logo, :enrollment_key, :unit_id, :color
end
