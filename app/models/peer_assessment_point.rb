# Historical Data for all points gained through submitting peer assessments.
#
# @!attribute [r] points
#   @return [Integer] The points awarded for this instance.
#
# @!attribute [r] date
#   @return [DateTime] The date that the points were awarded.
#
# @!attribute [r] student_id
#   @return [Integer] The id of the student that receive the points.
#
# @!attribute [r] reason_id
#   @return [Integer] The id of the Reason object containing the reason
#   for getting points.
#
# @!attribute [r] peer_assessment_id
#   @return [Integer] The id of the peer assessment that triggered the
#   PeerAssessmentPoint to be created.
#
# @!attribute [r] project_id
#   @return [Integer] The id of the project that the points were awarded for.
#
class PeerAssessmentPoint < ApplicationRecord
  belongs_to :project
  belongs_to :reason
  belongs_to :peer_assessment
  belongs_to :student

  validates_presence_of :points,
                        :date,
                        :project_id,
                        :student_id,
                        :reason_id,
                        :peer_assessment_id
end
