## Wrapper for the Student class when the current user is
#  a Student. Overrides methods of its associations to
#  execute custom SQL queries where needed.
class JWTAuth::CurrentUserStudent < JWTAuth::CurrentUser
  # Helper method to avoid checking the type
  # Returns false
  def lecturer?
    false
  end

  # Helper method to avoid checking the type
  # Returns true
  def student?
    true
  end

  def nickname_for_project_id(project_id)
    JoinTables::StudentsProject.select(:nickname)
                               .where(project_id: project_id, student_id: @id)[0]
                               .nickname
  rescue
    nil
  end

  # Override associations
  #

  def assignments(options = {})
    Assignment.joins(:students_projects)
              .where(['students_projects.student_id = ?', @id])
              .eager_load(options[:includes]).distinct
  end

  def units(options = {})
    Unit.joins(:students_projects)
        .where(['students_projects.student_id = ?', @id])
        .eager_load(options[:includes])
        .distinct
  end

  def projects(options = {})
    if options[:includes] && options[:includes].include?('students')
      options[:includes].delete('students')
      Project.joins(:students_projects)
             .where(['students_projects.student_id = ?', @id])
             .eager_load(options[:includes], students_projects: [:student])
    else
      Project.joins(:students_projects)
             .where(['students_projects.student_id = ?', @id])
             .eager_load(options[:includes])
    end
  end

  def iterations(options = {})
    includes =  if options[:includes]
                  options[:includes].unshift('pa_form')
                else
                  'pa_form'
                end
    Iteration.joins(:students_projects)
             .where(['students_projects.student_id = ?', @id])
             .eager_load(includes)
             .distinct
  end

  def pa_forms(options = {})
    PAForm.joins(:students_projects)
          .where(['students_projects.student_id = ?', @id])
          .eager_load(options[:includes])
          .distinct
  end

  def pa_forms_active(options = {})
    PAForm.active
          .joins(:students_projects)
          .where(['students_projects.student_id = ?', @id])
          .eager_load(options[:includes])
          .distinct
  end

  def peer_assessments(options = {})
    PeerAssessment.where("submitted_for_id = :id or submitted_by_id = :id", id: @id)
                  .eager_load(options[:includes])
  end

  def peer_assessments_for(options = {})
    PeerAssessment.where(['submitted_for_id = ?', @id])
                  .eager_load(options[:includes])
  end

  def peer_assessments_by(options = {})
    PeerAssessment.where(['submitted_by_id = ?', @id])
                  .eager_load(options[:includes])
  end

  def extensions
    Extension.joins(:students_projects)
             .where(['students_projects.student_id = ?', @id])
  end

  # The associations that the current_user can include in the query
  #
  # ##
  def assignment_associations
    %w(lecturer unit iterations projects).freeze
  end

  def unit_associations
    %w(lecturer department).freeze
  end

  def project_associations
    %w(assignment students lecturer).freeze
  end

  def iteration_associations
    %w(pa_form).freeze
  end

  def pa_form_associations
    %w(iteration).freeze
  end

  def peer_assessment_associations
    %w(pa_form submitted_by submitted_for).freeze
  end
end
