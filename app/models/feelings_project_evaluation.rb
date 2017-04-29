# Holds the percentage that a user feels a feeling
# for a project evaluation.
class FeelingsProjectEvaluation < ApplicationRecord
  belongs_to :feeling
  belongs_to :project_evaluation, inverse_of: :feelings_project_evaluations
  validates_presence_of :feeling, :project_evaluation, :percent
  validates_numericality_of :percent,
                            less_than_or_equal_to: 100,
                            greater_than_or_equal_to: 0
end
