# Wrapper for the Lecturer class when the current user is
# a Lecturer. Overrides methods of its associations to
# execute custom SQL queries where needed.
class JWTAuth::CurrentUserStudent < JWTAuth::CurrentUser
  # Check for whether the current user is a lecturer.
  # Returns false by default
  #
  # @return [Boolean] Returns false.
  def lecturer?
    false
  end

  # Check for whether the current user is a student.
  # Returns true by default
  #
  # @return [Boolean] Returns true.
  def student?
    true
  end

  # Returns the nickname of the student for the provided project_id
  #
  # @param project_id The project that the nickname will be returned for.
  #
  # @return [String|nil] Returns the nickname of the student for the
  #   provided project_id or nil if it could not be found.
  def nickname_for_project_id(project_id)
    StudentsProject.select(:nickname)
                   .where(project_id: project_id, student_id: @id)[0]
                   .nickname
  rescue
    nil
  end

  # Monkeypatches the assignments method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<Assignment>] An active record collection of the results.
  #
  def assignments(options = {})
    Assignment.joins(:students_projects)
              .where(['students_projects.student_id = ?', @id])
              .eager_load(options[:includes]).distinct
  end

  # Monkeypatches the units method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<Unit>] An active record collection of the results.
  #
  def units(options = {})
    Unit.joins(:students_projects)
        .where(['students_projects.student_id = ?', @id])
        .eager_load(options[:includes])
        .distinct
  end

  # Monkeypatches the projects method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<Project>] An active record collection of the results.
  #
  def projects(options = {})
    if options[:includes] && options[:includes].include?('students')
      options[:includes].delete('students')
      Project.joins(:students_projects)
             .where(['students_projects.student_id = ?', @id])
             .eager_load(options[:includes].map(&:to_sym).unshift(:students_projects))
    else
      includes =  if options[:includes]
                    options[:includes].map(&:to_sym).unshift({students_projects: :student})
                  else
                    [ { students_projects: :student }, { iterations: :pa_form }]
                  end

      Project.eager_load(includes)
             .where(['students_projects.student_id = ?', @id])

    end
  end

  # Monkeypatches the iterations method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<Iteration>] An active record collection of the results.
  #
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

  # Returns only the iterations that are currently active for the current user.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<Iteration>] An active record collection of the results.
  #
  def iterations_active(options = {})
    includes =  if options[:includes]
                  options[:includes].unshift('pa_form')
                else
                  'pa_form'
                end
    Iteration.active.joins(:students_projects)
             .where(['students_projects.student_id = ?', @id])
             .eager_load(includes)
             .distinct
  end

  # Monkeypatches the pa_forms method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<PaForm>] An active record collection of the results.
  #
  # def pa_forms(options = {})
  #   PaForm.joins(:students_projects)
  #         .where(['students_projects.student_id = ?', @id])
  #         .eager_load(options[:includes])
  #         .distinct
  # end

  # Returns only the pa_forms that belong to the current user that are currently
  # active.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<PaForm>] An active record collection of the results.
  #
  def pa_forms(options = {})
    includes =  if options[:includes]
                  options[:includes]
                else
                  [:projects, :students_projects]
                end
    PaForm.joins(:projects, :students_projects)
          .eager_load(includes)
          .where(['students_projects.student_id = ?', @id])
          .distinct
  end

  # Monkeypatches the peer_assessments method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<PeerAssessment>] An active record collection of the results.
  #
  def peer_assessments(options = {})
    PeerAssessment.where("submitted_for_id = :id or submitted_by_id = :id", id: @id)
                  .eager_load(options[:includes])
  end

  # Returns the peer_assessments that were submitted FOR the current user.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<PeerAssessment>] An active record collection of the results.
  #
  def peer_assessments_for(options = {})
    PeerAssessment.where(['submitted_for_id = ?', @id])
                  .eager_load(options[:includes])
  end

  # Returns the peer_assessments that were submitted BY the current user.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<PeerAssessment>] An active record collection of the results.
  #
  def peer_assessments_by(options = {})
    PeerAssessment.where(['submitted_by_id = ?', @id])
                  .eager_load(options[:includes])
  end

  # Monkeypatches the extensions method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @return [Array<Extension>] An active record collection of the results.
  #
  def extensions
    Extension.joins(:students_projects)
             .where(['students_projects.student_id = ?', @id])
  end

  # An array of all the associations that are allowed to be included
  # in an assignment query.
  #
  # @return [Array<String>] The association names as Strings.
  #
  def assignment_associations
    %w(lecturer unit iterations projects).freeze
  end

  # An array of all the associations that are allowed to be included
  # in an unit query.
  #
  # @return [Array<String>] The association names as Strings.
  #
  def unit_associations
    %w(lecturer assignments department).freeze
  end

  # An array of all the associations that are allowed to be included
  # in a project query.
  #
  # @return [Array<String>] The association names as Strings.
  #
  def project_associations
    %w(assignment unit students lecturer).freeze
  end

  # An array of all the associations that are allowed to be included
  # in an iteration query.
  #
  # @return [Array<String>] The association names as Strings.
  #
  def iteration_associations
    %w(pa_form).freeze
  end

  # An array of all the associations that are allowed to be included
  # in a pa_form query.
  #
  # @return [Array<String>] The association names as Strings.
  #
  def pa_form_associations
    %w(iteration).freeze
  end

  # An array of all the associations that are allowed to be included
  # in a peer_assessment query.
  #
  # @return [Array<String>] The association names as Strings.
  #
  def peer_assessment_associations
    %w(pa_form submitted_by submitted_for).freeze
  end
end
