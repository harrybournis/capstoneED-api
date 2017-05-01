module Marking
  module Persisters
    # Saves the PA scores in the database.
    class DatabasePersister
      # The persister is initialized with the
      # Iteration that was marked, and a
      # Marking::Results parameter, which contains
      # the scores and/or marks for each student.
      #
      # @param iteration [Iteration] The Iteration that
      #   the scores/marks will be saved for.
      # @param results [Marking::Results] The results
      #   scores calculation/marking for each student.
      #
      def initialize(iteration, results)
        @iteration = iteration
        @results = results
      end

      # Saves the results int the Database.
      # For each Student, it creates an IterationMark
      # for the provided iteration.
      def save!
        IterationMark.transaction do
          @results.scores.each do |student_id,score|
            IterationMark.create!(iteration_id: @iteration.id, student_id: student_id, pa_score: score)
          end
        end
        true
      end
    end
  end
end
