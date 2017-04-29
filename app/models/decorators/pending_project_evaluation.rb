module Decorators
  # Wraps an iteration and project to contain logic for whether there
  # are pending project evaluations currently. Objects of this class
  # will be serialized using the PendingProjecteEvaluationSerializer.
  # Automatically calculates the valid submission periods depending
  # on the expected no of evaluations per iteration.
  #
  # @author [harrybournis]
  #
  class PendingProjectEvaluation
    extend  ActiveModel::Naming
    include ActiveModel::Serialization

    attr_reader :project, :iteration, :no_of_evaluations_per_iteration

    # After calculating the deadline for a pending projece evaluation period
    # as a number from 0.0 to 1.0, this variable will indicate how far before this
    # upper limit the evaluation will be pending. If set to 0.1 and the upper limit
    # is 0.5 (the middle of the iteration), then 0.5 - 0.1 = 0.4 means that
    # the evaluation is pending during 40-50% of the total iteration duration.
    PROGRESS_START_OFFSET = 0.1

    # Takes an iteration, a project and an optional max number of evaluations
    # per iteration. If not supplied, the no of iteration will be taken by
    # calling ProjectEvaluation::NO_OF_EVALUATIONS_PER_ITERATION.
    #
    # @param iteration [Iteration] The Iteration
    # @param project [Project] The project that contains the students
    #   that will be included in team_answers.
    # @param no_of_evaluations_per_iteration [Integer] Optional. The number
    #   of expected project evaluation for each iteration.
    #
    # @raise [ArgumentError] If the no_of_evaluations_per_iteration is less that 1
    #
    def initialize(iteration, project, no_of_evaluations_per_iteration = nil)
      @project = project
      @iteration = iteration
      if no_of_evaluations_per_iteration && no_of_evaluations_per_iteration < 1
        raise ArgumentError, 'no_of_evaluations_per_iteration must be bigger than 1'
      end
      @no_of_evaluations_per_iteration = no_of_evaluations_per_iteration ||=
                                         ProjectEvaluation::NO_OF_EVALUATIONS_PER_ITERATION
    end

    # Returns a range of dates for the current pending submission period for the
    # Iteration. Returns nil if no submisison if currently pending.
    #
    # @return [Range<DateTime>, nil] Returns the range of dates that
    #   the Iteration can be evaluated. Returns nil if it can not
    #   be evaluated currently.
    #
    def current_submission_range
      iteration_start = iteration.start_date.to_i
      iteration_end = iteration.deadline.to_i
      now = DateTime.now.to_i
      progress = calculate_progress(now, iteration_start, iteration_end)

      @no_of_evaluations_per_iteration.times do |n|
        upper = (1.0 / (n + 1)).round 1
        lower = upper - PROGRESS_START_OFFSET

        if progress.between?(lower, upper)
          start_date = Time.at(iteration_start + ((iteration_end - iteration_start) * lower)).to_datetime
          end_date = Time.at(iteration_start + ((iteration_end - iteration_start) * upper)).to_datetime
          return start_date..end_date
        end
      end
      nil
    end

    # Returns true if there is a project evaluation can be submitted at the
    # current time.
    #
    # @return [Boolean] True if a project evaluation can be currently
    #   submtted, false if not.
    #
    def pending?
      !current_submission_range.nil?
    end

    # Returns an array of hashes that contain the students of the project,
    # with the project evaluation results if they have submitted it.
    #
    # @example
    #   [
    #     { student: { first_name: 'first', last_name: 'last'  }, percent_completed: 43 },
    #     { student: { first_name: 'first', last_name: 'last'  }, percent_completed: 43 }
    #   ]
    #
    # @return [Array<Hash>] [description]
    #
    def team_answers
      return @team_answers if @team_answers
      return nil unless submission_range = current_submission_range

      pe = ProjectEvaluation.eager_load(:user)
                            .joins(:user)
                            .where(['iteration_id = ? and project_id = ? and users.type = ?', @iteration.id, @project.id, 'Student'])
                            .where(date_submitted: submission_range)
      pe_user_ids = pe.map(&:user_id)
      students = @project.students.where.not(id: pe_user_ids)
      answers = []

      pe.each do |evaluation|
        answers << { student: evaluation.user, percent_completed: evaluation.percent_complete }
      end

      students.each do |student|
        answers << { student: student, percent_completed: nil }
      end

      @team_answers = answers
      return answers
    end

    # Returns the project id.
    #
    # @return [Integer] The project id
    #
    def project_id
      @project.id
    end

    # Returns the iteration id.
    #
    # @return [Integer] The iteration id.
    #
    def iteration_id
      @iteration.id
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
    # @private
    #
    # @return [Float] The progress as a float.
    #
    def calculate_progress(x, min, max)
      ((x - min) / (max - min).to_f).round(1)
    end
  end
end
