module PointsAward::Persisters

  class DefaultPersister < PointsAward::Persister
    def call
      with_transaction do

        if @points_board[:peer_assessment]
          @points_board[:peer_assessment].each do |pa|
            unless record = PeerAssessmentPoint.create(points: pa[:points],
                                                       reason_id: pa[:reason_id],
                                                       peer_assessment_id: @points_board.resource.id,
                                                       student_id: @points_board.student.id,
                                                       project_id: @points_board.project_id,
                                                       date: DateTime.now)
              @points_board.add_error(:peer_assessment, record.errors.full_messages)
            end
          end
        end

        if @points_board[:project_evaluation]
          @points_board[:project_evaluation].each do |pe|
            unless record = ProjectEvaluationPoint.create(points: pe[:points],
                                                          reason_id: pe[:reason_id],
                                                          project_evaluation_id: @points_board.resource.id,
                                                          student_id: @points_board.student.id,
                                                          project_id: @points_board.project_id,
                                                          date: DateTime.now)
              @points_board.add_error(:project_evaluation, record.errors.full_messages)
            end
          end
        end

        # if @points_board[:log]
        #   @points_board[:log].each do |pe|
        #     unless record = LogPoint.create(points: pe[:points],
        #                                     reason_id: pe[:reason_id],
        #                                     log_id: pe[:resource_id],
        #                                     student_id: @points_board.student.id,
        #                                     project_id: @points_board.resource.project_id,
        #                                     date: DateTime.now)
        #       @points_board.add_error(:log, record.errors.full_messages)
        #     end
        #   end
        # end
      end

      @points_board.persisted! unless @points_board.errors?
      @points_board
    end
  end
end
