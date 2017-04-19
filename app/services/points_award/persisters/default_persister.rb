# Module for the persister classes.
#
# @author [harrybournis]
#
# @!attribute [r] points_board
#   @return [PointsBoard] The pointsboard containing the
#     points that will be persisted.
#
# @!attribute points_persisted
#   @return [Array<PeerAssessmentPoint, ProjectEvaluationPoint, LogPoint>]
#     An array containing all the newly cretaed point objects.
#
module PointsAward::Persisters
  # The default Points persister that saves the
  # points in the database in the tables
  # PeerAssessmentPoint, ProjectEvaluationPoint, Logpoint.
  #
  # @author [harrybournis]
  #
  class DefaultPersister < PointsAward::Persister
    def initialize(points_board)
      super points_board
      @points_persisted = []
    end

    # Executes the action of the service. Checks the point
    # board for any points, and saves them to the appropriate
    # table according to the key in the points hash.
    # Add any validation errors during saving in the
    # errors hash of the PointsBoard. It wraps everything in
    # a transaction.
    #
    # Finally, if there were no errors, it calls persisted!
    # on the Pointsboard and assigns the persited points to
    # the points_persisted array.
    #
    # @return [type] [description]
    #
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

    # Helper method to add active record error to the
    # PointsBoard error hash.
    #
    # @param key [Symbol] The key that the errors will be
    #   stored under in the errors hash.
    # @param errors [Array<String>] An array of errors in strings.
    #
    def add_errors(key, errors)
      errors.each do |error|
        @points_board.add_error(key, error)
      end
    end

    # Updates the students total points based based on the points
    # in a point object. Needs a key in order to add any potential
    # error in the PoinsBoard error hash. If the points are successfully
    # saved, the record is added to the points_persisted array.
    #
    # @param key [Symbol] The key that should be used to save any
    #   errors during saving in the points board errors hash.
    # @param record [PeerAssessmentPoint, ProjectEvaluationPoint, LogPoint]
    #   The point object that will be used to update the total points.
    # @param project_id [Integer] The id of the project that the points
    #   will be updated for the student.
    #
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
