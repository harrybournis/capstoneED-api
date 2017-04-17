module PointsAward::Persisters

  class DefaultPersister < PointsAward::Persister
    def initialize(points_board)
      super points_board
      @points_persisted = []
    end

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
            unless record.save && update_total_points(:peer_assessment,
                                                      record,
                                                      @points_board.resource.project_id)
              add_errors :peer_assessment, record.errors.full_messages
            end
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

            unless record.save && update_total_points(:project_evaluation,
                                                      record,
                                                      @points_board.resource.project_id)
              add_errors :project_evaluation, record.errors.full_messages
            end
          end
        end

        if @points_board[:log]
          @points_board[:log].each do |log|
            record = LogPoint.new(points: log[:points],
                                  reason_id: log[:reason_id],
                                  student_id: @points_board.student.id,
                                  project_id: @points_board.resource.project_id,
                                  date: DateTime.now)

            unless record.save && update_total_points(:log,
                                                      record,
                                                      @points_board.resource.project_id)
              add_errors :log, record.errors.full_messages
            end
          end
        end
      end

      @points_board.persisted! unless @points_board.errors?
      @points_board.points_persisted = @points_persisted
      @points_board
    end

    private

    def add_errors(key, errors)
      errors.each do |error|
        @points_board.add_error(key, error)
      end
    end

    def update_total_points(key, record, project_id)
      if @points_board.student
                      .add_points_for_project_id(record.points, project_id)
        @points_persisted << record
      else
        add_errors key, ['Can not add points. Student does not belong in this project.']
      end
    end
  end
end
