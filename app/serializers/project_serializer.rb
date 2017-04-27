class ProjectSerializer < Base::BaseSerializer
  attributes :id, :assignment_id, :project_name, :team_name, :description,
   :logo, :enrollment_key, :unit_id, :color,
   :pending_project_evaluation, :points

  def pending_project_evaluation
    object.pending_evaluation?(current_user)
  end

  def points
    hash = {
      total: object.team_points,
      average: object.team_average
    }

    if scope.student?
      object.students_projects.each do |sp|
        if sp.student_id == scope.id
          hash[:personal] = sp.points
        end
      end
    end
    hash
  end
end
