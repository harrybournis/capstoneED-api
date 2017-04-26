# Methods for Project Evaluation. Included in Project
module Project::Evaluatable
  extend ActiveSupport::Concern

  # Project Health. The mean of the iteration_health of all iterations
  def project_health
    54
    # sum = 0
    # iterations.each { |iteration| sum += iteration.iteration_health }
    # (sum / iterations.length).round
  end

  # Team Health (static number right now. CHANGE)
  def team_health
    75
  end

  # Returns true if the student has a pending project evaluation
  # for the project. The project evaluation is considered pending if
  # 1) If no project evaluations have been submitted for it yet,
  # 2) the maximum number has not been already submitted for the current
  # iteration, 3) One has been submitted and we are curretly in the
  # second half of the iteration (chronologically).
  #
  # @return [Boolean] True if student can submit a project evaluation
  #   for this project.
  #
  def pending_evaluation?(student_id)
    # find it by looping to save many database queries
    found = false
    students_projects.each do |sp|
      found = true if sp.student_id == student_id
    end
    return false unless found

    return false unless iteration = current_iterations[0]

    submitted  =  project_evaluations.where(user_id: student_id, iteration_id: iteration.id)
    submitted_no = submitted.length

    return true if submitted_no == 0
    return false if submitted_no >= ProjectEvaluation::NO_OF_EVALUATIONS_PER_ITERATION

    middle_of_iteration = (iteration.start_date.to_i + iteration.deadline.to_i) / 2
    #((x - min) / (max - min).to_f).round 1
    if submitted_no == 1 &&
        submitted[0].date_submitted.to_i <= middle_of_iteration &&
        DateTime.now.to_i > middle_of_iteration
      return true
    end
    false
  end
end
