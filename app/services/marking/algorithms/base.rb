module Marking
  # Module Containing possible Marking Algorithm Classes
  #
  # @author [harrybournis]
  #
  module Algorithms
    # Superclass for MarkingAlgorithms. Contains
    # two class methods, .calculate_scores, and
    # .mark. Both methods return a MarkingAlgorithms::Results
    # object.
    #
    # @author [harrybournis]
    #
    class Base
      # Takes a PaAnswersTable and calculates the
      # peer assessment score of each student.
      # The score will be used in marking, to
      # determine what part of the group mark
      # each student will receive.
      #
      # @param pa_answers_table [CalculatePaScores::PaAnswersTable]
      #   A PaAnswersTable object with the peer
      #   assessment answers that each student gave
      #   about their teammates.
      #
      # @return [MarkingAlgorithms::Results] The results of
      #   the algorithm scoring.
      #
      def self.calculate_scores(pa_answers_table)
        raise ArgumentError, 'This method should be implemented in the subclass.'
      end

      # Calculates the final mark of the students using
      # their previously calculcated peer assessment
      # scores (from the .calculate_scores method)
      # and the Lecturer's mark for the group.
      #
      # @param student_scores [CalculatePaScores::StudentScores]
      #   The peer assessment scores that each student has received.
      #
      # @return [MarkingAlgorithms::Results] The results of
      #   the algorithm marking.
      #
      def mark(student_scores,
               mark,
               pa_weight_percentage = nil,
               penalty_percentage = nil)
        raise ArgumentError, 'This method should be implemented in the subclass.'
      end
    end
  end
end
