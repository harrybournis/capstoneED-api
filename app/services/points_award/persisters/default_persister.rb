require 'set'

module PointsAward::Persisters

  class DefaultPersister < PointsAward::Persister
    def call

      with_transaction do

        if @points_board[:peer_assessment]
          @points_board[:peer_assessment].each do |pa|
            record = PeerAssessmentPoint.new(points: pa[:points],
                                             reason_id: pa[:reason_id],
                                             peer_assessment_id: @points_board.resource.id,
                                             student_id: @points_board.student.id,
                                             project_id: @points_board.resource.project_id,
                                             date: DateTime.now)

            add_errors :peer_assessment, record.errors unless record.save
          end

        end

        if @points_board[:project_evaluation]
          @points_board[:project_evaluation].each do |pe|
            record = ProjectEvaluationPoint.new(points: pe[:points],
                                                reason_id: pe[:reason_id],
                                                project_evaluation_id: @points_board.resource.id,
                                                student_id: @points_board.student.id,
                                                project_id: @points_board.resource.project_id,
                                                date: DateTime.now)

            add_errors :project_evaluation, record.errors unless record.save
          end
        end

        if @points_board[:log]
          @points_board[:log].each do |pe|
            record = LogPoint.new(points: pe[:points],
                                  reason_id: pe[:reason_id],
                                  student_id: @points_board.student.id,
                                  project_id: @points_board.resource.project_id,
                                  date: DateTime.now)

            add_errors :log, record.errors unless record.save
          end
        end
      end

      @points_board.persisted! unless @points_board.errors?
      @points_board
    end

    private

    def add_errors(key, errors)
      errors.full_messages.each do |error|
        @points_board.add_error(key, error)
      end
    end
  end
end
