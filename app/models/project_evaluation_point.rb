# Historical Data for all points gained through submitting project evaluations.
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
#   @return [Integer] The id of the Reason for getting the points.
#
# @!attribute [r] project_evaluation_id
#   @return [Integer] The id of the project_evaluation that triggered the
#   ProjectEvaluationPoint to be created.
#
# @!attribute [r] project_id
#   @return [Integer] The id of the project that the points were awarded for.
#
class ProjectEvaluationPoint < ApplicationRecord
  belongs_to :project
  belongs_to :project_evaluation
  belongs_to :student

  validates_presence_of :points,
                        :date,
                        :project_id,
                        :student_id,
                        :reason_id,
                        :project_evaluation_id
end
