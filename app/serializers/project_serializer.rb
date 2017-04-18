class ProjectSerializer < Base::BaseSerializer
  attributes :id, :assignment_id, :project_name, :team_name, :description,
   :logo, :enrollment_key, :unit_id, :color, :team_points, :team_average,
   :pending_project_evaluation

  def pending_project_evaluation
    object.pending_evaluation?(current_user.id)
  end
end
