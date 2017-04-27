# Wrapper for the Lecturer class when the current user is
# a Lecturer. Overrides methods of its associations to
# execute custom SQL queries where needed.
class JWTAuth::CurrentUserLecturer < JWTAuth::CurrentUser
  # Check for whether the current user is a lecturer.
  # Returns true by default
  #
  # @return [Boolean] Returns true.
  def lecturer?
    true
  end

  # Check for whether the current user is a student.
  # Returns false by default
  #
  # @return [Boolean] Returns false.
  def student?
    false
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
    if options[:includes] && options[:includes].include?('projects')
      options[:includes].delete('projects')
      Assignment.eager_load(options[:includes].map(&:to_sym).push(:pa_forms, { projects: [:students_projects] })).where(lecturer_id: @id)
    else
      Assignment.eager_load(options[:includes]).where(lecturer_id: @id)
    end
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
    Unit.where(lecturer_id: @id).eager_load(options[:includes])
  end

  # Monkeypatches the departments method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<Department>] An active record collection of the results.
  #
  def departments(options = {})
    Department.joins(:units).where(['units.lecturer_id = ?', @id])
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

      Project.joins(:assignment)
             .eager_load(options[:includes], students_projects: [:student])
             .where(['assignments.lecturer_id = ?', @id])
    else
      includes =  if options[:includes]
                    options[:includes].unshift('students_projects')
                  else
                    'students_projects'
                  end

      Project.joins(:assignment)
             .eager_load(includes)
             .where(['assignments.lecturer_id = ?', @id])
    end
  end

  # Monkeypatches the questions method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @param options = {} [Hash] Optional.
  # @option includes [Array<String>] An array of the associations that will be
  #   eager loaded.
  #
  # @return [Array<Question>] An active record collection of the results.
  #
  def questions(options = {})
    Question.eager_load(options[:includes]).where(lecturer_id: @id)
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
    Iteration.joins(:assignment)
             .eager_load(includes)
             .where(['assignments.lecturer_id = ?', @id])
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
  def pa_forms(options = {})
    PaForm.joins(:iteration, :assignment)
          .eager_load(options[:includes])
          .where(['assignments.lecturer_id = ?', @id])
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
    PeerAssessment.joins(:assignment)
                  .eager_load(options[:includes])
                  .where(['assignments.lecturer_id = ?', @id])
  end

  # Monkeypatches the extensions method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @return [Array<Extension>] An active record collection of the results.
  #
  def extensions
    Extension.joins(:project, :assignment)
             .where(['assignments.lecturer_id = ?', @id])
  end

  # Monkeypatches the project_evaluations method of the current user to optimize the
  # joins and offer the ability to dynamically include different associations in
  # the response.
  #
  # @return [Array<ProjectEvaluation>] An active record collection of the results.
  #
  def project_evaluations
    ProjectEvaluation.where(user_id: @id)
  end

  # Monkeypatches the form_templates method of th current user to avoid loading the
  # user when trying to retrieve their form_templates.
  #
  # @return [Array<FormTemplate>] An active record collection of the results.
  #
  def form_templates
    FormTemplate.where(lecturer_id: @id)
  end

  #-------------------------------------------------------------------------#
  # Associations

  # An array of all the associations that are allowed to be included
  # in an assignment query.
  #
  # @return [Array<String>] The association names as Strings.
  #
  def assignment_associations
    %w(lecturer unit projects students iterations pa_forms).freeze
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
    %w(assignment students unit).freeze
  end

  # An array of all the associations that are allowed to be included
  # in an iteration query.
  #
  # @return [Array<String>] The association names as Strings.
  #
  def iteration_associations
    [].freeze
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
