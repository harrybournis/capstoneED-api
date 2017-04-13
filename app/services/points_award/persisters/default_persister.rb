module PointsAward::Persisters

  class DefaultPersister < PointsAward::Persister
    def call
      with_transaction do

        if @points_board[:peer_assessment]
          @points_board[:peer_assessment].each do |pa|
            unless record = PeerAssessmentPoint.create(pa)
              @points_board.add_error(:peer_assessment, record.errors.full_messages)
            end
          end
        end

        if @points_board[:project_evaluation]
          @points_board[:project_evaluation].each do |pe|
            unless record = PeerAssessmentPoint.create(pe)
              @points_board.add_error(:project_evaluation, record.errors.full_messages)
            end
          end
        end

        if @points_board[:log]
          @points_board[:log].each do |pe|
            unless record = LogPoint.create(pe)
              @points_board.add_error(:log, record.errors.full_messages)
            end
          end
        end

        @points_board.persisted! unless @points_board.errors?
        @points_board
      end
    end
  end
end
