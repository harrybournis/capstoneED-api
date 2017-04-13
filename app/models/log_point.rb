# Historical Data for all points gained through submitting logs.
#
# @!attribute [r] points
#   @return [Integer] The points awarded for this instance.
#
# @!attribute [r] date
#   @return [DateTime] The date that the points were awarded.
#
# @!attribute [r] reason_id
#   @return [Integer] The id of the Reason for getting the points.
#
# @!attribute [r] student_id
#   @return [Integer] The id of the student that receive the points.
#
# @!attribute [r] log_id
#   @return [Integer] The id of the log that triggered the LogPoint to be
#   created.
#
# @!attribute [r] project_id
#   @return [Integer] The id of the project that the points were awarded for.
#
class LogPoint < ApplicationRecord
  belongs_to :project
  belongs_to :student

  validates_presence_of :points,
                        :date,
                        :project_id,
                        :student_id,
                        :reason_id,
                        :log_id
end
