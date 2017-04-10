##
# Used in conjuction with LogPoints, PeerAssessmentPoints,
# ProjectEvaluationPoints to mark the reason for the points
# being awarded to the student.
#
# Contais a field called 'value' that works as an identifier for
# the source of the points gained. Currently all of the values match
# the game_settings table fields, but this could change in the future,
# adding possible reasons that can not be configured by the Lecturer
# in the game_settings table.
#
# @!attribute [r] id
#   @return [Integer] The id of the record.
#
# @!attribute [r] value
#   @return [Enum] The enum identifier of the reason.
#
class Reason < ApplicationRecord
  # The order of the enums should NOT be changed.
  #
  # The numbers are hardcoded to prevent accidental
  # rearrangement and corruption of the data.
  # Add any new enum at the bottom and increment the
  # number.
  enum value: {
    points_log: 0,
    points_log_first_of_day: 1,
    points_log_first_of_team: 2,
    points_log_first_of_assignment: 3,
    points_peer_assessment: 4,
    points_peer_assessment_first_of_team: 5,
    points_peer_assessment_first_of_assignment: 6,
    points_project_evaluation: 7,
    points_project_evaluation_first_of_team: 8,
    points_project_evaluation_first_of_assignment: 9,
    max_logs_per_day: 10
  }

  validates_presence_of :value
  validates_uniqueness_of :value
  
  has_many :log_points
end
