class ProjectSerializer < Base::BaseSerializer
  attributes :id, :assignment_id, :project_name, :team_name, :description,
   :logo, :enrollment_key, :unit_id, :color,
   :pending_project_evaluation, :points
  attribute :current_iteration_id, if: :pending

  def pending_project_evaluation
    if @pending_iteration = object.pending_evaluation(current_user)
      true
    else
      false
    end
  end

  def current_iteration_id
    @pending_iteration.id
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

  def pending
    !@pending_iteration.nil?
  end
end
