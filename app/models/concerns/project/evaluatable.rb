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
  # 1) The maximum number has not been already submitted for the current
  # iteration,
  # 2) If no project evaluations have been submitted for it yet and we
  # are either at the 40-50% or 90-100% of the iteration duration,
  # 3) One has been submitted and we are curretly in the
  # 90-100% of the iteration duration.
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

    return false if submitted_no >= ProjectEvaluation::NO_OF_EVALUATIONS_PER_ITERATION

    mid_start = 0.4
    end_start = 0.9
    iteration_start = iteration.start_date.to_i
    iteration_end = iteration.deadline.to_i
    now = DateTime.now.to_i
    progress = calculate_progress(now, iteration_start, iteration_end)

    return true if submitted_no == 0 && (progress.between?(mid_start, 0.5) ||
                                         progress.between?(end_start, 1))

    if submitted_no == 1 &&
       calculate_progress(submitted[0].date_submitted.to_i, iteration_start, iteration_end)
         .between?(mid_start, 0.5) &&
       progress.between?(end_start, 1)
      return true
    end

    false
  end

  private

  # Calculates the progress between x, witn min as 0 and max as 1.
  #
  # @param x [Integer] The number between min and max that we want
  #   the progress for.
  # @param min [Integer] The minimum point, that acts as 0 in the scale.
  #   Should be smaller than x.
  # @param max [Integer] The biggest points, that acts as 1 in the scale.
  #   Should be larger than x and min.
  #
  # @return [Float] The progress as a float.
  #
  def calculate_progress(x, min, max)
    ((x - min) / (max - min).to_f).round(1)
  end
end
