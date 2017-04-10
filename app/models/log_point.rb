# Historical Data for all points gained through submitting logs.
#
# @!attribute [r] points
#   @return [Integer] The points awarded for this instance.
#
# @!attribute [r] date
#   @return [DateTime] The date that the points were awarded.
#
# @!attribute [r] reason_id
#   @return [Integer] The id of the Reason object containing the reason
#   for getting points.
#
# @!attribute [r] log_id
#   @return [Integer] The id of the log that triggered the LogPoint to be
#   created.
#
# @!attribute [r] project_id
#   @return [Integer] The id of the project that the points were awarded for.
#
# @!attribute [r] students_project
#   @return [Integer] The students_project record that contains the
#   student_id, the project_id,
#   as well as the logs.
#
class LogPoint < ApplicationRecord
  belongs_to :project
  belongs_to :students_project, class_name: JoinTables::StudentsProject
  belongs_to :reason

  validates_presence_of :points, :date, :project_id, :students_project_id, :reason_id
end
