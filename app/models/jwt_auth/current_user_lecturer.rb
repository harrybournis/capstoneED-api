## Wrapper for the Lecturer class when the current user is
#  a Lecturer. Overrides methods of its associations to
#  execute custom SQL queries where needed.
class JWTAuth::CurrentUserLecturer < JWTAuth::CurrentUser
  # Helper method to avoid checking the type
  # Returns true
  def lecturer?
    true
  end

  # Helper method to avoid checking the type
  # Returns false
  def student?
    false
  end

  # Override associations
  #

  def assignments(options = {})
    Assignment.eager_load(options[:includes]).where(lecturer_id: @id)
  end

  def units(options = {})
    Unit.where(lecturer_id: @id).eager_load(options[:includes])
  end

  def departments(options = {})
    Department.joins(:units).where(['units.lecturer_id = ?', @id])
  end

  def projects(options = {})
    if options[:includes] && options[:includes].include?('students')
      options[:includes].delete('students')
      Project.joins(:assignment)
             .eager_load(options[:includes], students_projects: [:student])
             .where(['assignments.lecturer_id = ?', @id])
    else
      Project.joins(:assignment)
             .eager_load(options[:includes])
             .where(['assignments.lecturer_id = ?', @id])
    end
  end

  def questions(options = {})
    Question.eager_load(options[:includes]).where(lecturer_id: @id)
  end

  def iterations(options = {})
    includes =  if options[:includes]
                  options[:includes].unshift('pa_form')
                else
                  'pa_form'
                end
    Iteration.joins(:assignment)
             .eager_load(includes)
             .where(['assignments.lecturer_id = ?', @id])
  end

  def pa_forms(options = {})
    PaForm.joins(:iteration, :assignment)
          .eager_load(options[:includes])
          .where(['assignments.lecturer_id = ?', @id])
  end

  def peer_assessments(options = {})
    PeerAssessment.joins(:assignment)
                  .eager_load(options[:includes])
                  .where(['assignments.lecturer_id = ?', @id])
  end

  def extensions
    Extension.joins(:project, :assignment)
             .where(['assignments.lecturer_id = ?', @id])
  end

  def project_evaluations
    ProjectEvaluation.where(user_id: @id)
  end

  # The associations that the current_user can include in the query
  #
  # ##
  def assignment_associations
    %w(lecturer unit projects students iterations pa_forms).freeze
  end

  def unit_associations
    %w(lecturer assignments department).freeze
  end

  def project_associations
    %w(assignment students unit).freeze
  end

  def iteration_associations
    [].freeze
  end

  def pa_form_associations
    %w(iteration).freeze
  end

  def peer_assessment_associations
    %w(pa_form submitted_by submitted_for).freeze
  end
end
