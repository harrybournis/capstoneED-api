module Marking
  module Algorithms
    # Uses the algorithm of the WebPA project to calclualte
    # the score of the PeerAssessment and marke each student.
    #
    # @author [harrybournis]
    #
    class WebPaMarkingAlgorithm < Marking::Algorithms::Base
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
        results = Marking::Results.new

        scores_for_each_question = {}
        pa_answers_table.question_ids.each do |qid|
          scores_for_each_question[qid] = calculate_question(pa_answers_table, qid)
        end

        final_score = {}

        fudge_factor = unless pa_answers_table.everyone_submitted?
                         pa_answers_table.student_ids.length / (pa_answers_table.student_ids.length - pa_answers_table.did_not_submit_ids.length.to_d)
                       else
                         1
                       end

        scores_for_each_question.each do |question,student_scores|
          student_scores.each do |student_id,score|
            final_score[student_id] ||= 0
            final_score[student_id] += score * fudge_factor
          end
        end

        final_score.each do |student_id,score|
          # round the result to 14 decimal places, since
          # the database saves it that way.
          results.add_score student_id, (score / pa_answers_table.question_ids.length)#.round(14)
        end
        results
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
      def self.mark(student_scores,
                    mark,
                    pa_weight_percentage = nil,
                    penalty_percentage = nil)
      end

      private

      # Calculates the score for a single question
      #
      # @param results [Marking::PaAnswersTable] The answers table.
      # @param question_id [Integer] The question that will be calculated
      #
      def self.calculate_question(results, question_id)
        question_results = {}
        results.student_ids.each do |student_id|
          next if results.did_not_submit_ids.include? student_id
          marks_awarded_by_student = results.awarded_by(student_id, question_id).sum.to_d

          results[question_id][student_id].each do |assessed_id,mark|
            question_results[assessed_id] ||= 0
            question_results[assessed_id] += results[question_id][student_id][assessed_id] / marks_awarded_by_student
          end
        end
        question_results
      end
    end
  end
end
